# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'users/show' do
  let(:test_user) { create(:user) }

  before do
    allow(view).to receive(:user_signed_in?).and_return(false)
  end

  it 'displays the user email' do
    assign(:user, test_user)
    render
    expect(rendered).to match(test_user.email)
  end
end
