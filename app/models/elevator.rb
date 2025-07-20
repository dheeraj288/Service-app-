class Elevator < ApplicationRecord
  belongs_to :building

  enum status: { active: 0, inactive: 1, under_maintenance: 2 }
end