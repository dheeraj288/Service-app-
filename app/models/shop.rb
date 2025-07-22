class Shop < ApplicationRecord
  has_many :shops
  has_many :preventive_maintenances
  has_one :quickbooks_token
end
