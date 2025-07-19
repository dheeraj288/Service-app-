class CreateInvoices < ActiveRecord::Migration[7.1]
  def change
    create_table :invoices do |t|
      t.references :time_ticket, null: false, foreign_key: true
      t.string :invoice_number
      t.decimal :total_amount
      t.string :pdf_url
      t.string :status

      t.timestamps
    end
  end
end
