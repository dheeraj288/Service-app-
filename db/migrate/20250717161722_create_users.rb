class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :phone
      t.string :address
      t.string :role
      t.string :profile_image_url
      t.string :password_digest

      t.timestamps
    end
  end
end
