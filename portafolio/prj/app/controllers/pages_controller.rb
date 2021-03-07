# frozen_string_literal: true

# Pages Controller
class PagesController < ApplicationController
  def home
    return unless current_user

    @transactions = Transaction
                    .where('origin_id = ?', current_user.id)
                    .limit(10).order('created_at DESC')
    @debit_accounts = DebitAccount.where('user_id = ?', current_user.id)
    @credit_accounts = CreditAccount.where('user_id = ?', current_user.id)
    @checking_accounts = CheckingAccount.where('user_id = ?', current_user.id)
  end
end
