class CreateShops < ActiveRecord::Migration[7.1]
  def change
    create_table :shops do |t|
      t.string :name
      t.string :code

      t.timestamps
    end
    add_index :shops, :code, unique: true
  end
end
