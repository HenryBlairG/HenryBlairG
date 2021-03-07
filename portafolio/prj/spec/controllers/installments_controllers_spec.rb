# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InstallmentsController, type: :controller do
  describe 'POST #liquid_installments' do
    let(:user) { create(:user) }
    let(:credit_account) do
      CreditAccount.create(
        currency: 'CLP',
        liquid_balance: -1000,
        illiquid_balance: -1000,
        user: user
      )
    end
    let(:category) do
      Category.create(name: 'category1')
    end
    let(:transaction) do
      Transaction.create(
        amount: -200,
        category: category,
        description: 'simple transaction',
        origin: credit_account,
        currency: credit_account.currency,
        installments_qty: 1
      )
    end
    let(:installment) do
      Installment.create(
        place: 1, total_places: 1, unit_amount: transaction.amount.abs,
        liq_date: 10.days.from_now, total_amount: transaction.amount,
        credit_transaction: transaction
      )
    end

    before do
      sign_in user
    end

    it {
      sign_in user
      post 'liquid', params: { id: installment.id }
      expect(subject).to redirect_to user_credit_account_transaction_path(
        user, credit_account, transaction
      )
    }
  end

  describe 'POST invalid #liquid_installments' do
    let(:user) { create(:user) }
    let(:credit_account) do
      CreditAccount.create(
        currency: 'CLP',
        user: user
      )
    end
    let(:category) do
      Category.create(name: 'category1')
    end
    let(:transaction) do
      Transaction.create(
        amount: -200,
        category: category,
        description: 'simple transaction',
        origin: credit_account,
        currency: credit_account.currency,
        installments_qty: 1
      )
    end
    let(:installment) do
      Installment.create(
        place: 1, total_places: 1, unit_amount: transaction.amount.abs,
        liq_date: 10.days.from_now, total_amount: transaction.amount,
        credit_transaction: transaction
      )
    end

    it 'invalid liquid process' do
      sign_in user
      post 'liquid', params: { id: installment.id }
      expect(subject).to redirect_to user_credit_account_transaction_path(
        user, credit_account, transaction
      )
    end
  end

  describe 'POST #liquid_installments xx' do
    let(:user) { create(:user) }
    let(:credit_account) do
      CreditAccount.create(
        currency: 'CLP',
        liquid_balance: -1000,
        illiquid_balance: -1000,
        user: user
      )
    end
    let(:category) do
      Category.create(name: 'category1')
    end
    let(:transaction) do
      Transaction.create(
        amount: -200,
        category: category,
        description: 'simple transaction',
        origin: credit_account,
        currency: credit_account.currency,
        installments_qty: 1
      )
    end
    let(:installment) do
      Installment.create(
        place: 1, total_places: 1, unit_amount: transaction.amount.abs,
        liq_date: 10.days.from_now, total_amount: transaction.amount,
        credit_transaction: transaction
      )
    end

    it 'redirect to root if you don\'t have permissions' do
      post 'liquid', params: { id: installment.id }
      expect(response).to redirect_to root_path
    end
  end
end
