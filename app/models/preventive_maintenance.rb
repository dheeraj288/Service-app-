# app/models/preventive_maintenance.rb
class PreventiveMaintenance < ApplicationRecord
  belongs_to :shop
  belongs_to :customer, class_name: 'User'
  belongs_to :technician, class_name: 'User', optional: true

  STATUSES = %w[pending scheduled completed cancelled]

  validates :schedule_date, :frequency, :status, presence: true
  validates :status, inclusion: { in: STATUSES }

  # Calculate the next_run_date after completion
  def mark_completed!
    update!(
      status: 'completed',
      next_run_date: schedule_date.advance(**frequency_to_options)
    )
  end

  private

  # Convert frequency string like "monthly" to hash for advance()
  def frequency_to_options
    case frequency
    when 'daily'     then { days: 1 }
    when 'weekly'    then { weeks: 1 }
    when 'monthly'   then { months: 1 }
    when 'quarterly' then { months: 3 }
    else { days: 0 }
    end
  end
end
