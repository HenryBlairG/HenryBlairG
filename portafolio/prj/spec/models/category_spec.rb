# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Category, type: :model do
  describe 'attributes' do
    subject { described_class.new(name: 'something') }

    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
    it { should allow_value('viajes').for(:name) }
    it { should_not allow_value('').for(:name) }
  end

  describe 'columns' do
    subject(:category) { described_class.new }

    it do
      expect(subject).to have_db_column(:name)
        .of_type(:string)
    end
  end
end
