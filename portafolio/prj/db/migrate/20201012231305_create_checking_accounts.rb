class CreateCheckingAccounts < ActiveRecord::Migration[6.0]
  def change
    create_table :checking_accounts do |t|
      t.string :currency
      t.integer :liquid_balance, default: 0
      t.integer :illiquid_balance, default: 0

      t.timestamps
    end

    add_reference :checking_accounts, :user, foreign_key: true, null: false
  end
end
