class CreateQuickbooksTokens < ActiveRecord::Migration[7.1]
  def change
    create_table :quickbooks_tokens do |t|
      t.integer :shop_id
      t.string :access_token
      t.string :refresh_token
      t.string :realm_id
      t.datetime :expires_at

      t.timestamps
    end
  end
end
