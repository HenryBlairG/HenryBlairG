# frozen_string_literal: true
class AddInstallmentsQtyToTransactions < ActiveRecord::Migration[6.0]
  def self.up
    add_column :transactions, :installments_qty, :integer, :default => 1
  end

  def self.down
  end
end