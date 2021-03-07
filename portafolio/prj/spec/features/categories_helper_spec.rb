# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Categories', type: :feature do
  describe 'create category', type: :feature do
    let(:user) { create(:user, admin: true) }

    it 'creates new category' do
      login_as(user, scope: :user)
      visit root_path(user)
      click_link('Categories')
      click_link('Create category')
      within('#new_category') do
        fill_in 'Name', with: 'category1'
      end
      click_button 'commit'
      expect(page).to have_content 'Category was successfully created.'
    end
  end

  describe 'show categories', type: :feature do
    let(:user) { create(:user, admin: true) }

    it 'shows all categories' do
      (1..5).each do |_i|
        create(:category)
      end
      login_as(user, scope: :user)
      visit categories_path
      Category.all.each do |c|
        expect(page).to have_content c.name
      end
    end
  end
end
