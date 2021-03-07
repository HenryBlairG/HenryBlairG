# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CreditAccount, type: :model do
  describe 'attributes' do
    it { should validate_inclusion_of(:currency).in_array(%w[USD CLP]) }

    it {
      expect(subject).to validate_numericality_of(:liquid_balance)
        .is_less_than_or_equal_to(0)
    }

    it {
      expect(subject).to validate_numericality_of(:illiquid_balance)
        .is_less_than_or_equal_to(0)
    }

    it {
      expect(subject).to validate_numericality_of(:credit_limit)
        .is_less_than_or_equal_to(0)
    }

    it { should belong_to(:user) }
  end

  describe 'columns' do
    subject(:credit_account) { described_class.new }

    it do
      expect(subject).to have_db_column(:currency)
        .of_type(:string)
    end

    it do
      expect(subject).to have_db_column(:liquid_balance)
        .of_type(:integer)
    end

    it do
      expect(subject).to have_db_column(:illiquid_balance)
        .of_type(:integer)
    end

    it do
      expect(subject).to have_db_column(:credit_limit)
        .of_type(:integer)
    end

    it { should have_db_column(:user_id) }
  end

  describe 'validation errors' do
    it 'validates that credit_limit is lower than liquid_balance' do
      credit_account = described_class
                       .new(currency: 'USD', liquid_balance: -10,
                            illiquid_balance: 0, credit_limit: -5)
      expect(credit_account).to be_invalid
    end

    it 'validates that credit_limit is lower than illiquid_balance' do
      credit_account = described_class
                       .new(currency: 'USD', liquid_balance: 0,
                            illiquid_balance: -10, credit_limit: -5)
      expect(credit_account).to be_invalid
    end
  end
end
