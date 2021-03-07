# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TransactionsController, type: :controller do
  describe 'GET #new debit transaction non logged user' do
    let(:user) { create(:user) }
    let(:debit_account) do
      DebitAccount.create(
        currency: 'CLP',
        user: user
      )
    end

    before do
      get :new, params: {
        user_id: user.id,
        debit_account_id: debit_account.id
      }
    end

    it { should respond_with(302) }
    it { expect(response).to redirect_to(root_path) }
  end

  describe 'GET #new debit transaction for non owner user' do
    let(:user) { create(:user) }
    let(:user1) { create(:user) }
    let(:debit_account) do
      DebitAccount.create(
        currency: 'CLP',
        user: user
      )
    end

    before do
      sign_in user1
      get :new, params: {
        user_id: user1.id,
        debit_account_id: debit_account.id
      }
    end

    it { should respond_with(302) }
    it { expect(response).to redirect_to(root_path) }
  end

  describe 'GET #new debit transaction for admin user' do
    let(:user) { create(:user) }
    let(:user1) { create(:user, admin: true) }
    let(:debit_account) do
      DebitAccount.create(
        currency: 'CLP',
        user: user
      )
    end

    before do
      sign_in user1
      get :new, params: {
        user_id: user1.id,
        debit_account_id:
        debit_account.id
      }
    end

    it { should respond_with(200) }
    it { should render_template('new') }
  end

  describe 'GET #new debit transaction valid non admin user' do
    let(:user) { create(:user) }
    let(:debit_account) do
      DebitAccount.create(
        currency: 'CLP',
        user: user
      )
    end

    before do
      sign_in user
      get :new, params: {
        user_id: user.id,
        debit_account_id: debit_account.id
      }
    end

    it { should respond_with(200) }
    it { should render_template('new') }
  end

  describe 'POST #create valid debit transaction non admin owner user' do
    let(:user) { create(:user) }
    let(:debit_account) do
      DebitAccount.create(currency: 'CLP', user: user)
    end
    let(:category) do
      Category.create(name: 'category1')
    end

    let(:positive_amount_params_debit) do
      { user_id: user.id,
        debit_account_id: debit_account.id,
        transaction: {
          amount: 200,
          category: category.id,
          currency: debit_account.currency,
          type: 'INCOME'
        } }
    end

    before do
      sign_in user
      post :create, params: positive_amount_params_debit
    end

    it 'check 1 transaction created' do
      expect(debit_account.transactions.count).to eq(1)
    end

    it 'check new balance' do
      expect(
        debit_account.reload.liquid_balance
      ).to eq(
        positive_amount_params_debit[:transaction][:amount]
      )
    end

    it 'redirect user path' do
      expect(response).to redirect_to [user, debit_account]
    end
  end

  describe 'POST #create valid debit transaction admin non owner user' do
    let(:user) { create(:user, admin: true) }
    let(:debit_account) do
      DebitAccount.create(currency: 'CLP', user: user)
    end
    let(:category) do
      Category.create(name: 'category1')
    end

    let(:positive_amount_params_debit) do
      { user_id: user.id,
        debit_account_id: debit_account.id,
        transaction: {
          amount: 200,
          category: category.id,
          currency: debit_account.currency,
          type: 'INCOME'
        } }
    end

    before do
      sign_in user
      post :create, params: positive_amount_params_debit
    end

    it 'check 1 transaction created' do
      expect(debit_account.transactions.count).to eq(1)
    end

    it 'check new balance' do
      expect(
        debit_account.reload.liquid_balance
      ).to eq(
        positive_amount_params_debit[:transaction][:amount]
      )
    end

    it 'redirect user path' do
      expect(response).to redirect_to [user, debit_account]
    end
  end

  describe 'POST #create invalid debit transaction (balance broken)' do
    let(:user) { create(:user) }
    let(:debit_account) do
      DebitAccount.create(currency: 'CLP', user: user)
    end
    let(:prev_balance) { debit_account.liquid_balance }
    let(:category) do
      Category.create(name: 'category1')
    end

    let(:negative_amount_params_debit) do
      { user_id: user.id,
        debit_account_id: debit_account.id,
        transaction: {
          amount: 200,
          category: category.id,
          currency: debit_account.currency,
          type: 'EXPENSE'
        } }
    end

    before do
      sign_in user
      post :create, params: negative_amount_params_debit
    end

    it 'check no transactions created' do
      expect(debit_account.transactions.count).to eq(0)
    end

    it 'check restored balance (unchanged)' do
      expect(debit_account.reload.liquid_balance).to eq(prev_balance)
    end

    it 'redirect new transaction' do
      expect(response).to render_template('new')
    end
  end
end
