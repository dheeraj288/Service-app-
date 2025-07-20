class CreateQuotes < ActiveRecord::Migration[7.1]
  def change
    create_table :quotes do |t|
      t.references :time_ticket, null: false, foreign_key: true
      t.integer :shop_admin_id
      t.text :description
      t.decimal :amount
      t.string :status

      t.timestamps
    end
  end
end
