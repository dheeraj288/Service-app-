class User < ApplicationRecord
  has_secure_password

  belongs_to :shop, optional: true

  ROLES = %w[he_admin shop_admin technician customer]

  validates :role, inclusion: { in: ROLES }
  validates :email, presence: true, uniqueness: true

  attr_accessor :shop_code

  before_validation :assign_shop_from_code, if: -> { shop_code.present? }
  validate :shop_required_for_roles

  # ─── Role Helpers ─────────────────────────────────────────────────────────────
  def he_admin?      = role == 'he_admin'
  def shop_admin?    = role == 'shop_admin'
  def technician?    = role == 'technician'
  def customer?      = role == 'customer'

  private

  def shop_required_for_roles
    if %w[technician customer].include?(role) && shop_id.blank?
      errors.add(:shop_id, 'is required for this role')
    end
  end

  def assign_shop_from_code
    self.shop = Shop.find_by(code: shop_code)
    errors.add(:shop_code, 'is invalid') if self.shop.nil?
  end
end
