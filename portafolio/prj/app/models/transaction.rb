# frozen_string_literal: true

# Transaction Model
class Transaction < ApplicationRecord
  validates :amount, presence: true, numericality: { other_than: 0 }
  validates :installments_qty, numericality: { greater_than_or_equal_to: 1 }
  belongs_to :category

  belongs_to :origin, polymorphic: true
  has_many :installments, dependent: :destroy
end
