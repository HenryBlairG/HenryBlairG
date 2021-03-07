class CreateTransactions < ActiveRecord::Migration[6.0]
  def change
    create_table :transactions do |t|
      t.string :currency
      t.integer :origin_id
      t.string :description
      t.integer :amount, null: false
      t.string :status
      t.references :category, foreign_key: true

      t.timestamps
    end
  end
end
