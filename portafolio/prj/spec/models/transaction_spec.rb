# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Transaction, type: :model do
  describe 'attributes' do
    it { should belong_to(:category) }
    it { should belong_to(:origin) }
  end

  describe 'columns' do
    subject(:transaction) { described_class.new }

    it do
      expect(subject).to have_db_column(:currency)
        .of_type(:string)
    end

    it do
      expect(subject).to have_db_column(:description)
        .of_type(:string)
    end

    it do
      expect(subject).to have_db_column(:status)
        .of_type(:boolean)
    end

    it do
      expect(subject).to have_db_column(:origin_id)
        .of_type(:integer)
    end

    it do
      expect(subject).to have_db_column(:amount)
        .of_type(:integer)
    end
  end
end
