class Quote < ApplicationRecord
  belongs_to :time_ticket
  belongs_to :shop_admin, class_name: 'User', foreign_key: :shop_admin_id

  enum status: { draft: 'draft', submitted: 'submitted', approved: 'approved', rejected: 'rejected' }

  validates :description, :amount, :status, presence: true
end
