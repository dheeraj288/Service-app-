class User < ApplicationRecord
  has_secure_password

  # ─── Associations ─────────────────────────────────────────────────────
  belongs_to :shop, optional: true
  has_many :created_service_requests, class_name: 'ServiceRequest', foreign_key: :customer_id
  has_many :assigned_service_requests, class_name: 'ServiceRequest', foreign_key: :technician_id

  has_many :preventive_maintenances_as_customer, class_name: 'PreventiveMaintenance', foreign_key: 'customer_id'
  has_many :preventive_maintenances_as_technician, class_name: 'PreventiveMaintenance', foreign_key: 'technician_id'

    # app/models/user.rb
  has_many :buildings, foreign_key: :customer_id, dependent: :destroy
  accepts_nested_attributes_for :buildings

  has_many :service_requests


  # ─── Constants ────────────────────────────────────────────────────────
  ROLES = %w[he_admin shop_admin technician customer].freeze

  # ─── Validations ──────────────────────────────────────────────────────
  validates :email, presence: true, uniqueness: true
  validates :role, inclusion: { in: ROLES }
  validate :shop_required_for_technician_or_customer

  # ─── Virtual Attributes ───────────────────────────────────────────────
  attr_accessor :shop_code

  # ─── Callbacks ────────────────────────────────────────────────────────
  before_validation :assign_shop_from_code, if: -> { shop_code.present? }

  # ─── Role Helpers ─────────────────────────────────────────────────────
  def he_admin?     = role == 'he_admin'
  def shop_admin?   = role == 'shop_admin'
  def technician?   = role == 'technician'
  def customer?     = role == 'customer'

  private

  def shop_required_for_technician_or_customer
    if %w[technician customer].include?(role) && shop_id.blank?
      errors.add(:shop_id, 'is required for this role')
    end
  end

  def assign_shop_from_code
    self.shop = Shop.find_by(code: shop_code)
    errors.add(:shop_code, 'is invalid') if self.shop.nil?
  end
end
