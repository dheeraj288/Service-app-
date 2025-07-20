class CreateElevators < ActiveRecord::Migration[7.1]
  def change
    create_table :elevators do |t|
      t.string :identifier
      t.string :type
      t.integer :status, default: 0
      t.references :building, null: false, foreign_key: true

      t.timestamps
    end
  end
end
