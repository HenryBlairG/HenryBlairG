# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'User login', type: :feature do
  describe 'Successful log in', type: :feature do
    let(:user) { create(:user, password: '123456') }

    it 'logs in user' do
      visit root_path
      click_link('Log In')
      within('#new_user') do
        fill_in 'Email', with: user.email
        fill_in 'Password', with: '123456'
      end
      click_button 'Log in'
      expect(page).to have_content 'Signed in successfully.'
    end
  end

  describe 'Invalid login', type: :feature do
    let(:user) { create(:user, password: '123456') }

    it 'returns to form with invalid parameters' do
      visit root_path
      click_link('Log In')
      within('#new_user') do
        fill_in 'Email', with: user.email
        fill_in 'Password', with: '123'
      end
      click_button 'Log in'
      expect(page).to have_content 'Log in'
    end
  end
end
