class AddCreditLimitToCreditAccount < ActiveRecord::Migration[6.0]
  def change
    add_column :credit_accounts, :credit_limit, :integer, null: false, default: -1_000_000

  end
end
