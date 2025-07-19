class CreateServiceRequests < ActiveRecord::Migration[7.1]
  def change
    create_table :service_requests do |t|
      t.string :title
      t.text :description
      t.string :status
      t.datetime :eta
      t.datetime :assigned_at
      t.integer :customer_id
      t.integer :technician_id
      t.references :shop, null: false, foreign_key: true

      t.timestamps
    end
  end
end
