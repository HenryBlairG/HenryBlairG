# frozen_string_literal: true

# Debit Accounts Model
class DebitAccount < ApplicationRecord
  validates :currency, inclusion: { in: %w[USD CLP] }
  validates :liquid_balance, numericality: { greater_than_or_equal_to: 0 }
  validates :illiquid_balance, numericality: { greater_than_or_equal_to: 0 }

  belongs_to :user
  has_many :transactions, as: :origin, dependent: :destroy
end
