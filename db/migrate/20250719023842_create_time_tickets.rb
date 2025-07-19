class CreateTimeTickets < ActiveRecord::Migration[7.1]
  def change
    create_table :time_tickets do |t|
      t.references :service_request, null: false, foreign_key: true
      t.integer :technician_id
      t.datetime :start_time
      t.datetime :end_time
      t.decimal :total_hours
      t.string :status
      t.text :notes
      t.datetime :approved_at
      t.integer :approved_by

      t.timestamps
    end
  end
end
