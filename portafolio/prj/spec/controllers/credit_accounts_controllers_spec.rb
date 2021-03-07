# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CreditAccountsController, type: :controller do
  describe 'GET #show' do
    let(:user) { create(:user) }
    let(:user2) { create(:user) }
    let(:credit_account) { CreditAccount.create(currency: 'CLP', user: user) }

    it {
      sign_in user
      get :show, params: { user_id: user.id, id: credit_account.id }
      expect(subject).to respond_with(200)
    }

    it {
      sign_in user
      get :show, params: { user_id: user.id, id: credit_account.id }
      expect(subject).to render_template(
        'credit_accounts/show', 'layouts/application'
      )
    }

    it 'redirect to root if you don\'t have permissions' do
      sign_in user2
      get :show, params: { user_id: user2.id, id: credit_account.id }
      expect(response).to redirect_to root_path
    end
  end

  describe 'GET #new' do
    let(:user) { create(:user) }

    before do
      sign_in user
      get :new, params: { user_id: user.id }
    end

    it { should respond_with(200) }
    it { should render_template('new') }
  end

  describe 'POST #create' do
    let(:user) { create(:user) }
    let(:user2) { create(:user) }
    let(:params) do
      { user_id: user.id,
        credit_account: { currency: 'USD', liquid_balance: -1 } }
    end
    let(:invalid_params) do
      { user_id: user.id,
        credit_account: { currency: 'ABC' } }
    end

    it 'creates credit account if valid' do
      sign_in user
      expect { post :create, params: params }
        .to change(user.credit_accounts, :count).by(1)
    end

    it 'redirects to profile on succes' do
      sign_in user
      post :create, params: params
      expect(response).to redirect_to(user_path(id: user.id))
    end

    it 'does not create an invalid account' do
      sign_in user
      expect { post :create, params: invalid_params }
        .to change(user.credit_accounts, :count).by(0)
    end

    it 'renders new on fail' do
      sign_in user
      post :create, params: invalid_params
      expect(response).to render_template('new')
    end

    it 'redirect to root if you don\'t have permissions' do
      sign_in user2
      post :create, params: params
      expect(response).to redirect_to root_path
    end
  end
end
