class CreateBeers < ActiveRecord::Migration
  def change
    create_table :beers do |t|
      t.references :user, index: true, foreign_key: true, null: false
      t.references :creator, index: true, null: false
      t.integer :amount, default: 0, null: false
      t.timestamps null: false
    end

    # add_foreign_key :beers, :users, primary_key: :creator_id
  end
end
