# frozen_string_literal: true

# Credit Accounts Model
class CreditAccount < ApplicationRecord
  belongs_to :user
  has_many :transactions, as: :origin, dependent: :destroy

  validates :currency, inclusion: { in: %w[USD CLP] }
  validates :liquid_balance, numericality: { less_than_or_equal_to: 0 },
                             presence: true
  validates :illiquid_balance, numericality: { less_than_or_equal_to: 0 },
                               presence: true
  validates :credit_limit, numericality: { less_than_or_equal_to: 0 },
                           presence: true
  validate :credit_limit_lower_than_balances

  def credit_limit_lower_than_balances
    if liquid_balance < credit_limit
      errors[:base] << 'Balance liquido no puede ser menor al cupo asignado'
    elsif illiquid_balance < credit_limit
      errors[:base] << 'Balance no liquido no puede ser menor al cupo asignado'
    else
      true
    end
  end
end
