class CreateInstallments < ActiveRecord::Migration[6.0]
  def change
    create_table :installments do |t|
      t.integer :place
      t.integer :total_places
      t.integer :unit_amount, null: false
      t.integer :total_amount, null: false
      t.boolean :liq_status, null: false, default: false
      t.timestamp :liq_date
      t.references :transaction, foreign_key: true

      t.timestamps
    end
  end
end
