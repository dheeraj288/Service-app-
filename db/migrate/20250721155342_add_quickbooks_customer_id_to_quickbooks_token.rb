class AddQuickbooksCustomerIdToQuickbooksToken < ActiveRecord::Migration[7.1]
  def change
    add_column :quickbooks_tokens, :customer_id, :integer
  end
end
