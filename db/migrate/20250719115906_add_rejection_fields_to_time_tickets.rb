class AddRejectionFieldsToTimeTickets < ActiveRecord::Migration[7.1]
  def change
    add_column :time_tickets, :rejected_at, :datetime
    add_column :time_tickets, :rejected_by, :integer
    add_column :time_tickets, :rejection_reason, :text
  end
end
