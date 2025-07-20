class CreatePreventiveMaintenances < ActiveRecord::Migration[7.1]
  def change
    create_table :preventive_maintenances do |t|
      t.references :shop, null: false, foreign_key: true
      t.integer :customer_id
      t.integer :technician_id
      t.date :schedule_date
      t.string :frequency
      t.string :status
      t.date   :next_run_date

      t.timestamps
    end
  end
end
