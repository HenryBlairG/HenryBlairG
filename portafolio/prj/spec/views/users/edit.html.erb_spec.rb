# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'users/edit.html.erb' do
  let(:user) { create(:user) }

  before do
    assign(:user, user)
  end

  it 'displays the form' do
    render
    expect(rendered).to match 'Edit Profile'
  end
end
