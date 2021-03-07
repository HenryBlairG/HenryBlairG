# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'categories/index' do
  let(:user) { create(:user, admin: true) }

  before do
    allow(view).to receive(:user_signed_in?).and_return(false)
  end

  it 'displays all the categories' do
    assign(:categories, [])

    render

    expect(rendered).to match 'Categories'
  end
end
