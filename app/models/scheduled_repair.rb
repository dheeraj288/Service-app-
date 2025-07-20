class ScheduledRepair < ApplicationRecord
  belongs_to :shop
  belongs_to :building
  belongs_to :elevator
  belongs_to :customer, class_name: "User"
  belongs_to :technician, class_name: "User", optional: true

  enum status: {
    pending: "pending",
    assigned: "assigned",
    in_progress: "in_progress",
    completed: "completed"
  }

  validates :description, :scheduled_for, presence: true
end
