class CreateBuildings < ActiveRecord::Migration[7.1]
  def change
    create_table :buildings do |t|
      t.string :name
      t.string :address
      t.integer :customer_id

      t.timestamps
    end
  end
end
