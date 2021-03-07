# frozen_string_literal: true
class AddSuspendedToUsers < ActiveRecord::Migration[6.0]
  def self.up
    add_column :users, :suspended, :boolean, :default => false
  end

  def self.down
    remove_column :users, :suspended
  end
end