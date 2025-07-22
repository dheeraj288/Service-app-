class QuickbooksToken < ApplicationRecord
  belongs_to :shop

  validates :access_token, :refresh_token, :realm_id, :expires_at, presence: true
end