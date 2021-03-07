# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Installment, type: :model do
  describe 'columns' do
    subject(:installment) { described_class.new }

    it do
      expect(subject).to have_db_column(:place)
        .of_type(:integer)
    end

    it do
      expect(subject).to have_db_column(:total_places)
        .of_type(:integer)
    end

    it do
      expect(subject).to have_db_column(:unit_amount)
        .of_type(:integer)
    end

    it do
      expect(subject).to have_db_column(:total_amount)
        .of_type(:integer)
    end

    it do
      expect(subject).to have_db_column(:liq_status)
        .of_type(:boolean)
    end

    it do
      expect(subject).to have_db_column(:liq_date)
        .of_type(:datetime)
    end
  end
end
