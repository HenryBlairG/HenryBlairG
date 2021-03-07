# frozen_string_literal: true

# User Controller
class UsersController < ApplicationController
  before_action :set_user, only: %i[show edit update destroy change_suspension
                                    transaction_maker account_router]
  before_action :require_permission, only: %i[show edit update transaction_maker
                                              account_router]
  before_action :require_admin, only: %i[index destroy change_suspension]

  # GET /users
  def index
    @users = User.filter(params.slice(:email, :admin, :starts_with))
  end

  # GET /users/1
  def show; end

  # GET /users/1/edit
  def edit; end

  # PATCH/PUT /users/1
  def update
    if @user.update(user_params)
      redirect_to @user, notice: 'User was successfully updated.'
    else
      render :edit
    end
  end

  def transaction_maker; end

  def account_router
    if params[:user].key?('debit_account_id')
      redirect_to new_user_debit_account_transaction_path(
        @user, params[:user][:debit_account_id]
      )
    elsif params[:user].key?('credit_account_id')
      redirect_to new_user_credit_account_transaction_path(
        @user, params[:user][:credit_account_id]
      )
    elsif params[:user].key?('checking_account_id')
      redirect_to new_user_checking_account_transaction_path(
        @user, params[:user][:checking_account_id]
      )
    elsif params[:user].key?('debit_account_id_transf')
      redirect_to user_debit_account_transfer_path(
        @user, params[:user][:debit_account_id_transf]
      )
    elsif params[:user].key?('credit_account_id_transf')
      redirect_to user_credit_account_transfer_path(
        @user, params[:user][:credit_account_id_transf]
      )
    elsif params[:user].key?('checking_account_id_transf')
      redirect_to user_checking_account_transfer_path(
        @user, params[:user][:checking_account_id_transf]
      )
    else
      redirect_to transaction_maker_user_path(@user), notice: 'Invalid account'
    end
  end

  # PATCH /users/1
  def change_suspension
    @user.suspended = !@user.suspended
    @user.save
    if @user.suspended
      redirect_to users_url, notice: 'User was successfully suspended.'
    else
      redirect_to users_url, notice: 'User suspension status was cleared.'
    end
  end

  # DELETE /users/1
  def destroy
    @user.destroy
    redirect_to users_url, notice: 'User was successfully destroyed.'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def user_params
    params.require(:user).permit(:email, :password)
  end

  def require_permission
    is_admin = user_signed_in? && current_user.admin
    correct_user = user_signed_in? && current_user == @user
    has_permission = is_admin || correct_user
    notice = 'You don\'t have the permissions to do that'

    redirect_to root_path, notice: notice unless has_permission
  end

  def require_admin
    is_admin = user_signed_in? && current_user.admin
    notice = 'You don\'t have the permissions to do that'

    redirect_to root_path, notice: notice unless is_admin
  end
end
