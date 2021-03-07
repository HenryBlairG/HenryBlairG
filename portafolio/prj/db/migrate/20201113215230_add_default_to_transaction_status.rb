# frozen_string_literal: true

class AddDefaultToTransactionStatus < ActiveRecord::Migration[6.0]
  def self.up
    remove_column :transactions, :status, :string
    add_column :transactions, :status, :boolean, :default => false
  end

  def self.down
    remove_column :transactions, :status, :boolean
    add_column :transactions, :status, :string
  end
end