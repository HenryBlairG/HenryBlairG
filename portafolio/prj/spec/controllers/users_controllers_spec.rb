# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  describe 'GET #show' do
    let(:test_user) { create(:user) }

    before do
      sign_in test_user
      get :show, params: { id: test_user.id }
    end

    it { should respond_with(200) }
    it { should render_template('show') }
  end

  describe 'GET #show as guest' do
    let(:test_user) { create(:user) }

    before { get :show, params: { id: test_user.id } }

    it { should redirect_to(root_path) }
  end

  describe 'GET #index' do
    let(:test_user) { create(:user, admin: true, email: 'user@gmail.com') }

    before do
      sign_in test_user
      get :index, params: { email: 'user@gmail.com' }
    end

    it { should respond_with(200) }
    it { should render_template('index') }
  end

  describe 'GET #index as non admin' do
    let(:test_user) { create(:user) }

    before do
      sign_in test_user
      get :index
    end

    it { should redirect_to root_path }
  end

  describe 'GET #edit' do
    let(:test_user) { create(:user) }

    before do
      sign_in test_user
      get :edit, params: { id: test_user.id }
    end

    it { should respond_with(200) }
    it { should render_template('edit') }
  end

  describe 'PUT #update' do
    let(:user) { create(:user) }
    let(:user2) { create(:user) }
    let(:params) do
      { id: user.id,
        user: { email: 'valid@email' } }
    end
    let(:invalid_params) do
      { id: user.id,
        user: { email: 'invalid' } }
    end

    it 'updates user if valid' do
      sign_in user
      post :update, params: params
      expect(user.reload.email).to eq(params[:user][:email])
    end

    it 'redirects to show on succes' do
      sign_in user
      post :update, params: params
      expect(response).to redirect_to(user_path(id: user.id))
    end

    it 'does not update an invalid user' do
      post :update, params: invalid_params
      old_email = user.email
      expect(user.reload.email).to eq(old_email)
    end

    it 'renders edit on fail' do
      sign_in user
      post :update, params: invalid_params
      expect(response).to render_template(:edit)
    end

    it 'redirect to root if you don\'t have permissions' do
      sign_in user2
      post :update, params: params
      expect(response).to redirect_to root_path
    end
  end

  describe 'DELETE #destroy' do
    let!(:user) { create(:user, admin: true) }
    let(:user2) { create(:user) }

    it 'deletes user' do
      sign_in user
      expect { post :destroy, params: { id: user.id } }
        .to change(User, :count).by(-1)
    end

    it 'redirects to index' do
      sign_in user
      post :destroy, params: { id: user.id }
      expect(response).to redirect_to(users_path)
    end

    it 'redirect to root if you don\'t have permissions' do
      sign_in user2
      post :destroy, params: { id: user2.id }
      expect(response).to redirect_to root_path
    end
  end

  describe 'POST #change_suspension' do
    let!(:user) { create(:user, admin: true) }
    let(:non_suspended_user) { create(:user) }
    let(:suspended_user) { create(:user, suspended: true) }

    it 'redirects to index' do
      sign_in user
      post :change_suspension, params: { id: non_suspended_user.id }
      expect(response).to redirect_to(users_path)
    end

    it 'change suspension of a non suspended user' do
      sign_in user
      expect { post :change_suspension, params: { id: non_suspended_user.id } }
        .to change { non_suspended_user.reload.suspended }.from(false).to(true)
    end

    it 'change suspension of a suspended user' do
      sign_in user
      expect { post :change_suspension, params: { id: suspended_user.id } }
        .to change { suspended_user.reload.suspended }.from(true).to(false)
    end
  end

  describe 'POST #transfer_maker user debit transaction and transfer' do
    let(:user) { create(:user) }
    let(:debit_account) do
      DebitAccount.create(currency: 'CLP', user: user, liquid_balance: 1000)
    end

    let(:params) do
      { id: user.id,
        user: { debit_account_id: debit_account.id } }
    end
    let(:params_transf) do
      { id: user.id,
        user: { debit_account_id_transf: debit_account.id } }
    end

    before do
      sign_in user
    end

    it {
      post :account_router, params: params
      expect(response).to(redirect_to(new_user_debit_account_transaction_path(
                                        user, debit_account
                                      )))
    }

    it {
      post :account_router, params: params_transf
      expect(response).to(
        redirect_to(user_debit_account_transfer_path(user, debit_account))
      )
    }
  end

  describe 'POST #transfer_maker user checking transaction and transfer' do
    let(:user) { create(:user) }
    let(:checking_account) do
      CheckingAccount.create(currency: 'CLP', user: user, liquid_balance: 1000)
    end

    let(:params) do
      { id: user.id,
        user: { checking_account_id: checking_account.id } }
    end
    let(:params_transf) do
      { id: user.id,
        user: { checking_account_id_transf: checking_account.id } }
    end

    before do
      sign_in user
    end

    it {
      post :account_router, params: params
      expect(response)
        .to(redirect_to(
              new_user_checking_account_transaction_path(user, checking_account)
            ))
    }

    it {
      post :account_router, params: params_transf
      expect(response).to(
        redirect_to(user_checking_account_transfer_path(user, checking_account))
      )
    }
  end

  describe 'POST #transfer_maker user credit transaction and transfer' do
    let(:user) { create(:user) }
    let(:credit_account) do
      CreditAccount.create(currency: 'CLP', user: user)
    end

    let(:params) do
      { id: user.id,
        user: { credit_account_id: credit_account.id } }
    end
    let(:params_transf) do
      { id: user.id,
        user: { credit_account_id_transf: credit_account.id } }
    end

    before do
      sign_in user
    end

    it {
      post :account_router, params: params
      expect(response)
        .to(redirect_to(
              new_user_credit_account_transaction_path(user, credit_account)
            ))
    }

    it {
      post :account_router, params: params_transf
      expect(response).to(
        redirect_to(user_credit_account_transfer_path(user, credit_account))
      )
    }
  end

  describe 'POST #transfer_maker user invalid account' do
    let(:user) { create(:user) }
    let(:params) do
      { id: user.id,
        user: { invalid_account_id: 1 } }
    end

    before do
      sign_in user
      post :account_router, params: params
    end

    it {
      expect(response).to(
        redirect_to(transaction_maker_user_path(user))
      )
    }
  end
end
