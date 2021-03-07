class AddOriginToTransaction < ActiveRecord::Migration[6.0]
  def change
    add_column :transactions, :origin_type, :string
    add_index :transactions, [:origin_type, :origin_id]

  end
end
