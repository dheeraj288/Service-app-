class TimeTicket < ApplicationRecord
  belongs_to :service_request
  # app/models/time_ticket.rb
  has_one :quote, dependent: :destroy


  belongs_to :technician, class_name: 'User', foreign_key: :technician_id
  # app/models/time_ticket.rb
  belongs_to :rejected_by_user, class_name: 'User', foreign_key: 'rejected_by', optional: true
  belongs_to :approved_by_user, class_name: 'User', foreign_key: 'approved_by', optional: true


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
