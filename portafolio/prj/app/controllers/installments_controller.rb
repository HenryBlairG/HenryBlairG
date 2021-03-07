# frozen_string_literal: true

# Installments Controller
class InstallmentsController < ApplicationController
  before_action :set_user
  before_action :set_account
  before_action :require_permission

  # POST /installments/:installment_id/
  def liquid
    @installment.liq_status = true
    @installment.liq_date = DateTime.current
    @account.liquid_balance -= @installment.unit_amount
    @account.illiquid_balance += @installment.unit_amount
    if @account.valid?
      @account.save
      @installment.save
      check_transaction_status
      notice = 'Liquidated Installment'
    else
      # Error al liquidar cuota. Cupo lleno para saldo liquido
      notice =
        'Error: Not possible to liquidate installment. Liquid Balance Full'
    end
    transaction = @installment.credit_transaction
    redirect_to user_credit_account_transaction_path(
      current_user, @account, transaction
    ), notice: notice
  end

  private

  def check_transaction_status
    transaction = @installment.credit_transaction
    transaction.status = transaction.installments.map(&:liq_status).reduce(:&)
    transaction.save
  end

  def installment_params
    params[:installment] = { id: params[:id] }
    params.require(:installment).permit(:id)
  end

  def set_account
    @installment = Installment.find_by(id: installment_params[:id])
    @account = @installment.credit_transaction.origin
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = current_user
  end

  def require_permission
    is_admin = user_signed_in? && current_user.admin
    correct_user = user_signed_in? && current_user == @user
    is_owner_user = @account.user == @user
    has_permission = is_admin || (correct_user && is_owner_user)
    notice = 'You don\'t have the permissions to do that'

    redirect_to root_path, notice: notice unless has_permission
  end
end
