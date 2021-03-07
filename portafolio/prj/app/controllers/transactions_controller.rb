# frozen_string_literal: true

# Transactions Controller
# rubocop:disable Metrics/ClassLength
class TransactionsController < ApplicationController
  include CurrencyControllerConcern
  before_action :set_user
  before_action :set_account
  before_action :retrieve_categories
  before_action :require_permission
  before_action :set_transfer_params, only: %i[create_transfer]

  # GET /users/:user_id/accounts/:account_id/transactions/new
  def new
    @transaction = Transaction.new
  end

  def show
    @transaction = Transaction.find_by(id: params[:id])
    @installments = @transaction.installments
  end

  # POST /users/:user_id/debit_accounts
  def create
    prepare_transaction
    save_and_redirect
  end

  # GET /users/:user_id/accounts/:account_id/transfer
  def transfer
    @url = case @account_type
           when :debit_account
             user_debit_account_create_transfer_path(@user, @account)

           when :credit_account
             user_credit_account_create_transfer_path(@user, @account)

           else
             user_checking_account_create_transfer_path(@user, @account)
           end
  end

  # POST /users/:user_id/accounts/:account_id/transfer
  def create_transfer
    unless @other_account
      return redirect_to user_checking_account_transfer_path(
        @user, @account
      ), notice: 'Accounts aren\'t valid'
    end

    @account.liquid_balance += @transfer_origin.amount
    @other_account.liquid_balance += @transfer_destination.amount

    if (@account.valid? && @transfer_origin.valid?) &&
       (@other_account.valid? && @transfer_destination.valid?)
      @account.save
      @transfer_origin.save
      @other_account.save
      @transfer_destination.save
      redirect_to [@user, @account], notice: 'Transfer successfully created.'
    else
      @account.liquid_balance += @transfer_origin.amount
      @other_account.liquid_balance -= @transfer_destination.amount
      redirect_to user_checking_account_transfer_path(
        @user, @account
      ), notice: 'Transaction isn\'t valid'
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:user_id])
  end

  # prepare transaction.
  def prepare_transaction
    @transaction = Transaction.new(transaction_params)
    @transaction.origin = @account
    @transaction.category = @category
    return nil unless @transaction.valid?

    @amount = transaction_params[:amount].to_i * get_exchange(
      @transaction.currency, @account.currency
    )
    if @gasto_ingreso == 'EXPENSE'
      @transaction.amount = -@transaction.amount.abs
      if @account.instance_of? CreditAccount
        @account.illiquid_balance -= @amount
      else
        @account.liquid_balance -= @amount
      end
    else # =="INGRESO"
      @account.liquid_balance += @amount
    end
  end

  def save_and_redirect
    if @account.valid? && @transaction.valid?
      @account.save
      @transaction.save
      assign_installments
      redirect_to [@user, @account], notice: 'Transaction successfully created.'
    else
      revert_amount_on_account
      flash[:notice] = 'Transaction does not respect balance restrictions'
      render :new
    end
  end

  def assign_installments
    unit_amount = @transaction.amount.abs / @transaction.installments_qty
    module_div_amount = @transaction.amount.abs % @transaction.installments_qty
    ins = nil
    (1..@transaction.installments_qty).each do |quota_i|
      ins = Installment.create(place: quota_i, unit_amount: unit_amount,
                               liq_date: (30 * quota_i).days.from_now,
                               total_amount: @transaction.amount,
                               total_places: @transaction.installments_qty)
      @transaction.installments << ins
    end
    ins.unit_amount += module_div_amount
    ins.save
  end

  def revert_amount_on_account
    return nil unless @amount

    if @gasto_ingreso == 'EXPENSE'
      if @account.instance_of? CreditAccount
        @account.illiquid_balance += @amount
      else
        @account.liquid_balance += @amount
      end
    else # =="INGRESO"
      @account.liquid_balance -= @amount
    end
    @transaction.amount = @transaction.amount.abs
  end

  def set_account
    if params.key?('debit_account_id')
      @account_type = :debit_account
      @account = DebitAccount.find(params[:debit_account_id])

    elsif params.key?('credit_account_id')
      @account_type = :credit_account
      @account = CreditAccount.find(params[:credit_account_id])

    else # params.key?('checking_account_id') #there's no option due to routing
      @account_type = :checking_account
      @account = CheckingAccount.find(params[:checking_account_id])
    end
  end

  def set_transfer_params
    @other_account = nil
    case params[@account_type][:destination_account_type]
    when 'Debit'
      @other_account = DebitAccount
                       .find_by(id:
                        params[@account_type][:destination_account_id])

    when 'Credit'
      @other_account = CreditAccount
                       .find_by(id:
                        params[@account_type][:destination_account_id])

    else # Corriente
      @other_account = CheckingAccount
                       .find_by(id:
                        params[@account_type][:destination_account_id])
    end
    return nil unless @other_account

    @category = Category
                .find_by(id: params[@account_type][:category].to_i)

    @transfer_origin = Transaction.new
    @transfer_origin.origin = @account
    @transfer_origin.category = @category
    @transfer_origin.currency = params[@account_type][:currency]
    @transfer_origin.amount = -(params[@account_type][:amount] || 0).to_i.abs
    @transfer_origin.description = params[@account_type][:description]

    @transfer_destination = Transaction.new
    @transfer_destination.origin = @other_account
    @transfer_destination.category = @category
    @transfer_destination.currency = @other_account.currency
    @transfer_destination.amount = (params[@account_type][:amount] ||
      0).to_i.abs * get_exchange(@transfer_origin.currency,
                                 @transfer_destination.currency)
    @transfer_destination.description = params[@account_type][:description]
  end

  def retrieve_categories
    @categories = Category.all
  end

  # Only allow a list of trusted parameters through.
  def transaction_params
    @category = Category.find_by(id: params[:transaction][:category].to_i)
    @gasto_ingreso = params[:transaction][:type]
    params.require(:transaction).permit(:currency, :amount, :description,
                                        :installments_qty)
  end

  def require_permission
    is_admin = user_signed_in? && current_user.admin
    approved_user = !@user.suspended
    correct_user = user_signed_in? && current_user == @user && approved_user
    is_owner_user = @account.user == @user
    has_permission = is_admin || (correct_user && is_owner_user)
    notice = 'You don\'t have the permissions to do that'

    redirect_to root_path, notice: notice unless has_permission
  end
end
# rubocop:enable Metrics/ClassLength
