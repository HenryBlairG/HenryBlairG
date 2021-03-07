# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TransactionsController, type: :controller do
  describe 'GET #transfer non logged user' do
    let(:user) { create(:user) }
    let(:credit_account) do
      CreditAccount.create(
        currency: 'CLP',
        user: user
      )
    end

    before do
      get :transfer, params: {
        user_id: user.id,
        credit_account_id: credit_account.id
      }
    end

    it { should respond_with(302) }
    it { expect(response).to redirect_to(root_path) }
  end

  describe 'GET #transfer for non owner user' do
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
      get :transfer, params: {
        user_id: user.id,
        debit_account_id: debit_account.id
      }
    end

    it { should respond_with(302) }
    it { expect(response).to redirect_to(root_path) }
  end

  describe 'GET #new transfer for admin user' do
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
      get :transfer, params: {
        user_id: user1.id,
        credit_account_id:
        credit_account.id
      }
    end

    it { should respond_with(200) }
    it { should render_template('transfer') }
  end

  describe 'GET #transfer for valid non admin user' do
    let(:user) { create(:user) }
    let(:debit_account) do
      DebitAccount.create(
        currency: 'CLP',
        user: user
      )
    end

    before do
      sign_in user
      get :transfer, params: {
        user_id: user.id,
        debit_account_id: debit_account.id
      }
    end

    it { should respond_with(200) }
    it { should render_template('transfer') }
  end

  describe 'GET #transfer for valid non admin user checking' do
    let(:user) { create(:user) }
    let(:checking_account) do
      CheckingAccount.create(
        currency: 'CLP',
        user: user
      )
    end

    before do
      sign_in user
      get :transfer, params: {
        user_id: user.id,
        checking_account_id: checking_account.id
      }
    end

    it { should respond_with(200) }
    it { should render_template('transfer') }
  end

  describe 'POST #create_transfer non existent account' do
    let(:user) { create(:user) }
    let(:account) do
      CheckingAccount.create(currency: 'CLP', user: user, liquid_balance: 1000)
    end
    let(:category) do
      Category.create(name: 'category1')
    end

    let(:params) do
      { user_id: user.id,
        checking_account_id: account.id,
        checking_account: {
          amount: 1000,
          category: category.id,
          currency: account.currency,
          destination_account_type: 'Debit',
          destination_account_id: -1
        } }
    end

    before do
      sign_in user
      post :create_transfer, params: params
    end

    it 'check transaction not created' do
      expect(account.transactions.count).to eq(0)
    end

    it 'redirect to new transfer path' do
      expect(response).to(
        redirect_to(user_checking_account_transfer_path(user, account))
      )
    end
  end

  describe 'POST #create_transfer valid transaction' do
    let(:user) { create(:user) }
    let(:account) do
      CheckingAccount.create(currency: 'CLP', user: user, liquid_balance: 1000)
    end
    let(:account2) do
      CreditAccount.create(currency: 'USD', user: user, liquid_balance: -800)
    end
    let(:category) do
      Category.create(name: 'category1')
    end

    let(:params) do
      { user_id: user.id,
        checking_account_id: account.id,
        checking_account: {
          amount: 1000,
          category: category.id,
          currency: account.currency,
          destination_account_type: 'Credit',
          destination_account_id: account2.id
        } }
    end

    before do
      sign_in user
      post :create_transfer, params: params
    end

    it 'check transaction created' do
      expect(account.transactions.count).to eq(1)
    end

    it 'check transaction 2 created' do
      expect(account2.transactions.count).to eq(1)
    end

    it 'check new balance' do
      expect(account.reload.liquid_balance).to eq(0)
    end

    it 'check new balance 2' do
      expect(account2.reload.liquid_balance).to eq(0)
    end

    it 'redirect user path' do
      expect(response).to redirect_to [user, account]
    end
  end

  describe 'POST #create_transfer invalid destination account' do
    let(:user) { create(:user) }
    let(:account) do
      DebitAccount.create(currency: 'CLP', user: user, liquid_balance: 1000)
    end
    let(:account2) do
      CheckingAccount.create(currency: 'CLP', user: user, liquid_balance: 1000)
    end
    let(:category) do
      Category.create(name: 'category1')
    end

    let(:params) do
      { user_id: user.id,
        debit_account_id: account.id,
        debit_account: {
          amount: 10_000,
          category: category.id,
          currency: account.currency,
          destination_account_type: 'Corriente',
          destination_account_id: 12_321
        } }
    end

    before do
      sign_in user
      post :create_transfer, params: params
    end

    it 'check transaction not created' do
      expect(account.transactions.count).to eq(0)
    end

    it 'check transaction 2 not created' do
      expect(account2.transactions.count).to eq(0)
    end

    it 'redirect to new transfer path' do
      expect(response).to redirect_to(
        user_checking_account_transfer_path(user, account)
      )
    end
  end

  describe 'POST #create_transfer invalid transaction amount' do
    let(:user) { create(:user) }
    let(:account) do
      DebitAccount.create(currency: 'CLP', user: user, liquid_balance: 1000)
    end
    let(:account2) do
      CheckingAccount.create(currency: 'CLP', user: user, liquid_balance: 1000)
    end
    let(:category) do
      Category.create(name: 'category1')
    end

    let(:params) do
      { user_id: user.id,
        debit_account_id: account.id,
        debit_account: {
          amount: 2_000_000,
          category: category.id,
          currency: account.currency,
          destination_account_type: 'Corriente',
          destination_account_id: account2.id
        } }
    end

    before do
      sign_in user
      post :create_transfer, params: params
    end

    it 'check transaction not created' do
      expect(account.transactions.count).to eq(0)
    end

    it 'check transaction 2 not created' do
      expect(account2.transactions.count).to eq(0)
    end

    it 'redirect to new transfer path' do
      expect(response).to redirect_to(
        user_checking_account_transfer_path(user, account)
      )
    end
  end

  describe 'POST #create_transfer invalid user' do
    let(:user) { create(:user) }
    let(:user2) { create(:user) }
    let(:account) do
      DebitAccount.create(currency: 'CLP', user: user, liquid_balance: 1000)
    end
    let(:account2) do
      CheckingAccount.create(currency: 'CLP', user: user, liquid_balance: 1000)
    end

    let(:params) do
      { user_id: user.id,
        debit_account_id: account.id,
        debit_account: {
          amount: 10_000,
          category: Category.create(name: 'category1').id,
          currency: account.currency,
          destination_account_type: 'Corriente',
          destination_account_id: account2.id
        } }
    end

    before do
      sign_in user2
      post :create_transfer, params: params
    end

    it { should respond_with(302) }
    it { expect(response).to redirect_to(root_path) }
  end
end
