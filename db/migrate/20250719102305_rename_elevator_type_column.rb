class RenameElevatorTypeColumn < ActiveRecord::Migration[7.1]
  def change
    rename_column :elevators, :type, :elevator_type
  end
end