class ServiceRequest < ApplicationRecord
  # ─── Associations ─────────────────────────────────────────────────────
  belongs_to :customer,   class_name: 'User', foreign_key: :customer_id
  belongs_to :technician, class_name: 'User', foreign_key: :technician_id, optional: true
  belongs_to :shop

  # ─── Enums ────────────────────────────────────────────────────────────
  enum status: {
    pending:  'pending',
    assigned: 'assigned',
    resolved: 'resolved'
  }

  # ─── Validations ──────────────────────────────────────────────────────
  validates :title, :description, :customer_id, :shop_id, :status, presence: true
  validates :status, inclusion: { in: statuses.keys }
end


