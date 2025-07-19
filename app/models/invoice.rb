class Invoice < ApplicationRecord
  belongs_to :time_ticket

  before_create :generate_invoice_number

  private

  def generate_invoice_number
    self.invoice_number = "INV-#{SecureRandom.hex(5).upcase}"
  end
end
