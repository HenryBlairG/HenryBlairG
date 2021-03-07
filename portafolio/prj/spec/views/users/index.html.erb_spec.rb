# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'users/index' do
  before do
    allow(view).to receive(:user_signed_in?).and_return(false)
  end

  it 'displays all the users' do
    assign(:users, [])

    render

    expect(rendered).to match 'Users'
  end
end
