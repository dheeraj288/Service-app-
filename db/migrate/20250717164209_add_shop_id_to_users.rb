class AddShopIdToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :shop_id, :integer
  end
end
