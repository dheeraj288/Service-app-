class TimeTicket < ApplicationRecord
  belongs_to :service_request
  belongs_to :technician, class_name: 'User', foreign_key: :technician_id, optional: true
  belongs_to :approver, class_name: 'User', optional: true

  validates :start_time, :end_time, :total_hours, presence: true

  before_validation :calculate_total_hours
  has_one :invoice


  private

  def calculate_total_hours
    if start_time && end_time
      self.total_hours = ((end_time - start_time) / 1.hour).round(2)
    end
  end
end
