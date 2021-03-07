# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'attributes' do
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:encrypted_password) }
    it { should validate_presence_of(:password) }
    it { should validate_length_of(:password).is_at_least(6) }
  end

  describe 'uniqueness' do
    it { should validate_uniqueness_of(:email).case_insensitive }
  end

  describe 'columns' do
    subject(:user) { described_class.new }

    it do
      expect(subject).to have_db_column(:email)
        .of_type(:string).with_options(null: false)
    end

    it do
      expect(subject).to have_db_column(:encrypted_password)
        .of_type(:string).with_options(null: false)
    end

    it { should have_db_column(:admin).of_type(:boolean) }
  end

  describe 'indexes' do
    it { should have_db_index(:email).unique }
  end
end
