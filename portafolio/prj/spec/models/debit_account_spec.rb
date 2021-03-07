# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DebitAccount, type: :model do
  describe 'attributes' do
    it { should validate_inclusion_of(:currency).in_array(%w[USD CLP]) }

    it {
      expect(subject).to validate_numericality_of(:liquid_balance)
        .is_greater_than_or_equal_to(0)
    }

    it {
      expect(subject).to validate_numericality_of(:illiquid_balance)
        .is_greater_than_or_equal_to(0)
    }

    it { should belong_to(:user) }
  end

  describe 'columns' do
    subject(:debit_account) { described_class.new }

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

    it { should have_db_column(:user_id) }
  end
end
