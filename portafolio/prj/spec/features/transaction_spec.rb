# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Transactions', type: :feature do
  describe 'create transaction in debit account', type: :feature do
    let(:user) { create(:user) }
    let!(:category) { create(:category) }
    let(:account) do
      DebitAccount.create(currency: 'CLP', user: user, liquid_balance: 1000)
    end

    it 'creates transaction in debit' do
      login_as(user, scope: :user)
      visit user_debit_account_path(user, account)
      click_link('New')
      within('.form_box') do
        fill_in 'Amount', with: 100
        fill_in 'Description', with: 'abc'
        within('#categories') do
          choose(id: category.id.to_s)
        end
      end
      click_button 'commit'
      expect(page).to have_content 'Transaction successfully created.'
    end
  end

  describe 'create transaction in checking account', type: :feature do
    let(:user) { create(:user) }
    let!(:category) { create(:category) }
    let(:account) do
      CheckingAccount.create(currency: 'CLP', user: user, liquid_balance: 1000)
    end

    it 'creates transaction in checking' do
      login_as(user, scope: :user)
      visit user_checking_account_path(user, account)
      click_link('New')
      within('.form_box') do
        fill_in 'Amount', with: 100
        fill_in 'Description', with: 'abc'
        within('#categories') do
          choose(id: category.id.to_s)
        end
      end
      click_button 'commit'
      expect(page).to have_content 'Transaction successfully created.'
    end
  end

  describe 'create transaction in credit account', type: :feature do
    let(:user) { create(:user) }
    let!(:category) { create(:category) }
    let(:account) { CreditAccount.create(currency: 'CLP', user: user) }

    it 'creates transaction in credit' do
      login_as(user, scope: :user)
      visit user_credit_account_path(user, account)
      click_link('New')
      within('.form_box') do
        fill_in 'Amount', with: 100
        fill_in 'Description', with: 'abc'
        within('#categories') do
          choose(id: category.id.to_s)
        end
      end
      click_button 'commit'
      expect(page).to have_content 'Transaction successfully created.'
    end
  end
end
