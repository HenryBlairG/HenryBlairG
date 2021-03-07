# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TransactionsController, type: :controller do
  describe 'GET #new checking transaction non logged user' do
    let(:user) { create(:user) }
    let(:checking_account) do
      CheckingAccount.create(
        currency: 'CLP',
        user: user
      )
    end

    before do
      get :new, params: {
        user_id: user.id,
        checking_account_id: checking_account.id
      }
    end

    it { should respond_with(302) }
    it { expect(response).to redirect_to(root_path) }
  end

  describe 'GET #new checking transaction for non owner user' do
    let(:user) { create(:user) }
    let(:user1) { create(:user) }
    let(:checking_account) do
      CheckingAccount.create(
        currency: 'CLP',
        user: user
      )
    end

    before do
      sign_in user1
      get :new, params: {
        user_id: user1.id,
        checking_account_id: checking_account.id
      }
    end

    it { should respond_with(302) }
    it { expect(response).to redirect_to(root_path) }
  end

  describe 'GET #new checking transaction for admin user' do
    let(:user) { create(:user) }
    let(:user1) { create(:user, admin: true) }
    let(:checking_account) do
      CheckingAccount.create(
        currency: 'CLP',
        user: user
      )
    end

    before do
      sign_in user1
      get :new, params: {
        user_id: user1.id,
        checking_account_id:
        checking_account.id
      }
    end

    it { should respond_with(200) }
    it { should render_template('new') }
  end

  describe 'GET #new checking transaction valid non admin user' do
    let(:user) { create(:user) }
    let(:checking_account) do
      CheckingAccount.create(
        currency: 'CLP',
        user: user
      )
    end

    before do
      sign_in user
      get :new, params: {
        user_id: user.id,
        checking_account_id: checking_account.id
      }
    end

    it { should respond_with(200) }
    it { should render_template('new') }
  end

  describe 'POST #create valid checking transaction non admin owner user' do
    let(:user) { create(:user) }
    let(:checking_account) do
      CheckingAccount.create(currency: 'CLP', user: user)
    end
    let(:category) do
      Category.create(name: 'category1')
    end

    let(:positive_amount_params_checking) do
      { user_id: user.id,
        checking_account_id: checking_account.id,
        transaction: {
          amount: 200,
          category: category.id,
          currency: checking_account.currency,
          type: 'INGRESO'
        } }
    end

    before do
      sign_in user
      post :create, params: positive_amount_params_checking
    end

    it 'check 1 transaction created' do
      expect(checking_account.transactions.count).to eq(1)
    end

    it 'check new balance' do
      expect(
        checking_account.reload.liquid_balance
      ).to eq(
        positive_amount_params_checking[:transaction][:amount]
      )
    end

    it 'redirect user path' do
      expect(response).to redirect_to [user, checking_account]
    end
  end

  describe 'POST #create valid checking transaction admin non owner user' do
    let(:user) { create(:user, admin: true) }
    let(:checking_account) do
      CheckingAccount.create(currency: 'CLP', user: user)
    end
    let(:category) do
      Category.create(name: 'category1')
    end

    let(:positive_amount_params_checking) do
      { user_id: user.id,
        checking_account_id: checking_account.id,
        transaction: {
          amount: 200,
          category: category.id,
          currency: 'USD',
          type: 'INCOME'
        } }
    end

    before do
      sign_in user
      post :create, params: positive_amount_params_checking
    end

    it 'check 1 transaction created' do
      expect(checking_account.transactions.count).to eq(1)
    end

    it 'check new balance' do
      expect(
        checking_account.reload.liquid_balance
      ).to eq(
        positive_amount_params_checking[:transaction][:amount] * 1.25
      )
    end

    it 'redirect user path' do
      expect(response).to redirect_to [user, checking_account]
    end
  end

  describe 'POST #create valid cred transaction negative balance' do
    let(:user) { create(:user) }
    let(:checking_account) do
      CheckingAccount.create(currency: 'CLP', user: user)
    end
    let(:category) do
      Category.create(name: 'category1')
    end

    let(:negative_amount_params_checking) do
      { user_id: user.id,
        checking_account_id: checking_account.id,
        transaction: {
          amount: 200,
          category: category.id,
          currency: checking_account.currency,
          type: 'EXPENSE'
        } }
    end

    before do
      sign_in user
      post :create, params: negative_amount_params_checking
    end

    it 'check 1 transaction created' do
      expect(checking_account.transactions.count).to eq(1)
    end

    it 'check new balance' do
      expect(
        checking_account.reload.liquid_balance
      ).to eq(
        -1 * negative_amount_params_checking[:transaction][:amount]
      )
    end

    it 'redirect user path' do
      expect(response).to redirect_to [user, checking_account]
    end
  end
end
