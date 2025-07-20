class Building < ApplicationRecord
  belongs_to :customer, class_name: 'User'
  has_many :elevators, dependent: :destroy

  accepts_nested_attributes_for :elevators
end
