class CreateDebitAccounts < ActiveRecord::Migration[6.0]
  def change
    create_table :debit_accounts do |t|
      t.string :currency
      t.integer :liquid_balance, default: 0
      t.integer :illiquid_balance, default: 0
    end

    add_reference :debit_accounts, :user, foreign_key: true, null: false
  end
end
