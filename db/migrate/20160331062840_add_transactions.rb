class AddTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.references :user, index: true, foreign_key: true, null: false
      t.float :money, default: 0, null: false
      t.integer :amount, default: 0, null: false
      t.boolean :paid, default: false, null: false
      t.timestamps null: false
    end

    add_column :users, :transaction_total, :float, null: false, default: 0
    remove_reference :beers, :creator
  end
end
