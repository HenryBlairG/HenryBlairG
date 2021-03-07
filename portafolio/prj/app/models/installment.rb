# frozen_string_literal: true

# Installment Model
class Installment < ApplicationRecord
  belongs_to :credit_transaction, class_name: 'Transaction',
                                  foreign_key: :transaction_id,
                                  inverse_of: :installments
end
