# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TransactionsController, type: :controller do
  describe 'GET #new credit transaction non logged user' do
    let(:user) { create(:user) }
    let(:credit_account) do
      CreditAccount.create(
        currency: 'CLP',
        user: user
      )
    end

    before do
      get :new, params: {
        user_id: user.id,
        credit_account_id: credit_account.id
      }
    end

    it { should respond_with(302) }
    it { expect(response).to redirect_to(root_path) }
  end

  describe 'GET #new debit transaction for non owner user' do
    let(:user) { create(:user) }
    let(:user1) { create(:user) }
    let(:credit_account) do
      CreditAccount.create(
        currency: 'CLP',
        user: user
      )
    end

    before do
      sign_in user1
      get :new, params: {
        user_id: user1.id,
        credit_account_id: credit_account.id
      }
    end

    it { should respond_with(302) }
    it { expect(response).to redirect_to(root_path) }
  end

  describe 'GET #new credit transaction for admin user' do
    let(:user) { create(:user) }
    let(:user1) { create(:user, admin: true) }
    let(:credit_account) do
      CreditAccount.create(
        currency: 'CLP',
        user: user
      )
    end

    before do
      sign_in user1
      get :new, params: {
        user_id: user1.id,
        credit_account_id:
        credit_account.id
      }
    end

    it { should respond_with(200) }
    it { should render_template('new') }
  end

  describe 'GET #new credit transaction valid non admin user' do
    let(:user) { create(:user) }
    let(:credit_account) do
      CreditAccount.create(
        currency: 'CLP',
        user: user
      )
    end

    before do
      sign_in user
      get :new, params: {
        user_id: user.id,
        credit_account_id: credit_account.id
      }
    end

    it { should respond_with(200) }
    it { should render_template('new') }
  end

  describe 'GET #show credit transaction valid' do
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
        currency: credit_account.currency
      )
    end

    before do
      sign_in user
      get :show, params: {
        user_id: user.id,
        credit_account_id: credit_account.id,
        id: transaction.id
      }
    end

    it { should respond_with(200) }
    it { should render_template('show') }
  end

  describe 'POST #create valid cred transaction non admin owner user' do
    let(:user) { create(:user) }
    let(:credit_account) do
      CreditAccount.create(currency: 'CLP', user: user)
    end
    let(:category) do
      Category.create(name: 'category1')
    end

    let(:negative_amount_params_credit) do
      { user_id: user.id,
        credit_account_id: credit_account.id,
        transaction: {
          amount: 200,
          category: category.id,
          currency: credit_account.currency,
          type: 'EXPENSE'
        } }
    end

    before do
      sign_in user
      post :create, params: negative_amount_params_credit
    end

    it 'check 1 transaction created' do
      expect(credit_account.transactions.count).to eq(1)
    end

    it 'check new balance' do
      expect(
        credit_account.reload.illiquid_balance
      ).to eq(
        -1 * negative_amount_params_credit[:transaction][:amount]
      )
    end

    it 'redirect user path' do
      expect(response).to redirect_to [user, credit_account]
    end
  end

  describe 'POST #create valid cred transaction admin non owner user' do
    let(:user) { create(:user, admin: true) }
    let(:credit_account) do
      CreditAccount.create(currency: 'CLP', user: user)
    end
    let(:category) do
      Category.create(name: 'category1')
    end

    let(:negative_amount_params_credit) do
      { user_id: user.id,
        credit_account_id: credit_account.id,
        transaction: {
          amount: 200,
          category: category.id,
          currency: credit_account.currency,
          type: 'EXPENSE'
        } }
    end

    before do
      sign_in user
      post :create, params: negative_amount_params_credit
    end

    it 'check 1 transaction created' do
      expect(credit_account.transactions.count).to eq(1)
    end

    it 'check new balance' do
      expect(
        credit_account.reload.illiquid_balance
      ).to eq(
        -1 * negative_amount_params_credit[:transaction][:amount]
      )
    end

    it 'redirect user path' do
      expect(response).to redirect_to [user, credit_account]
    end
  end

  describe 'POST #create invalid cred transaction (invalid amount)' do
    let(:user) { create(:user) }
    let(:credit_account) do
      CreditAccount.create(currency: 'CLP', user: user)
    end
    let(:prev_balance) { credit_account.liquid_balance }
    let(:category) do
      Category.create(name: 'category1')
    end

    let(:positive_amount_params_credit) do
      { user_id: user.id,
        credit_account_id: credit_account.id,
        transaction: {
          amount: credit_account.credit_limit + 1,
          category: category.id,
          currency: credit_account.currency,
          type: 'EXPENSE'
        } }
    end

    before do
      sign_in user
      post :create, params: positive_amount_params_credit
    end

    it 'check no transactions created' do
      expect(credit_account.transactions.count).to eq(0)
    end

    it 'check restored balance (unchanged)' do
      expect(credit_account.reload.liquid_balance).to eq(prev_balance)
    end

    it 'redirect new transaction' do
      expect(response).to render_template('new')
    end
  end

  describe 'POST #create invalid cred transaction (ingreso invalid amount)' do
    let(:user) { create(:user) }
    let(:credit_account) do
      CreditAccount.create(currency: 'CLP', user: user)
    end
    let(:prev_balance) { credit_account.liquid_balance }
    let(:category) do
      Category.create(name: 'category1')
    end

    let(:positive_amount_params_credit) do
      { user_id: user.id,
        credit_account_id: credit_account.id,
        transaction: {
          amount: credit_account.credit_limit.abs + 1,
          category: category.id,
          currency: credit_account.currency,
          type: 'INGRESO'
        } }
    end

    before do
      sign_in user
      post :create, params: positive_amount_params_credit
    end

    it 'check no transactions created' do
      expect(credit_account.transactions.count).to eq(0)
    end

    it 'check restored balance (unchanged)' do
      expect(credit_account.reload.liquid_balance).to eq(prev_balance)
    end

    it 'redirect new transaction' do
      expect(response).to render_template('new')
    end
  end
end
