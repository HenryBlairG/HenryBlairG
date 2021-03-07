# frozen_string_literal: true

# Checking Accounts Model
class CheckingAccount < ApplicationRecord
  validates :currency, inclusion: { in: %w[USD CLP] }
  belongs_to :user
  has_many :transactions, as: :origin, dependent: :destroy
end
