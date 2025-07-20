class CreateScheduledRepairs < ActiveRecord::Migration[7.1]
  def change
    create_table :scheduled_repairs do |t|

      t.references :shop, foreign_key: true
      t.references :building, foreign_key: true
      t.references :elevator, foreign_key: true
      t.integer :customer_id
      t.integer :technician_id
      t.text :description
      t.datetime :scheduled_for
      t.string :status, default: "pending"

      t.timestamps
    end
  end
end
