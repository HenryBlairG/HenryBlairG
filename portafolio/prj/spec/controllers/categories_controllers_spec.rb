# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CategoriesController, type: :controller do
  describe 'GET #new category' do
    let(:user) { create(:user, admin: true) }

    before do
      sign_in user
      get :new
    end

    it {
      sign_in user
      expect(subject).to respond_with(200)
    }

    it { should render_template('new') }
  end

  describe 'GET #index categories' do
    let(:user) { create(:user, admin: true) }

    before do
      sign_in user
      get :index
    end

    it { should respond_with(200) }
    it { should render_template('index') }
  end

  describe 'redirect GET #index' do
    let(:user) { create(:user) }

    before do
      sign_in user
      get :index
    end

    it { should respond_with(302) }
    it { should redirect_to root_path }
  end

  describe 'POST #create category' do
    let(:user) { create(:user, admin: true) }
    let(:user2) { create(:user, admin: false) }
    let(:params) do
      { user_id: user.id,
        category: { name: 'viajes' } }
    end
    let(:invalid_params) do
      { user_id: user.id,
        category: { name: '' } }
    end

    it 'creates category if valid' do
      sign_in user
      expect { post :create, params: params }
        .to change(Category.all, :count).by(1)
    end

    it 'redirects to categories index on success' do
      sign_in user
      post :create, params: params
      expect(subject).to redirect_to(categories_path)
    end

    it 'does not create an invalid category' do
      sign_in user
      expect { post :create, params: invalid_params }
        .to change(Category.all, :count).by(0)
    end

    it 'renders new category on fail' do
      sign_in user
      post :create, params: invalid_params
      expect(subject).to render_template('new')
    end

    it 'redirect to root if you don\'t have permissions' do
      sign_in user2
      post :create, params: params
      expect(subject).to redirect_to root_path
    end
  end
end
