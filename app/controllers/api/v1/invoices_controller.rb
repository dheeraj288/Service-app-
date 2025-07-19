class Api::V1::InvoicesController < ApplicationController
  before_action :authorize_request

  def generate
    ticket = TimeTicket.find(params[:time_ticket_id])
    return render json: { error: 'Unauthorized' }, status: :unauthorized unless shop_admin_or_he_admin?

    invoice_pdf = GenerateInvoicePdf.new(ticket).call
    render json: { success: true, invoice: invoice_pdf }
  end

  # in controller
	def download
	  ticket = TimeTicket.find(params[:id])
	  return render json: { error: 'Unauthorized' }, status: :unauthorized unless shop_admin_or_he_admin?

	  invoice_pdf = GenerateInvoicePdf.new(ticket).call
	  file_path = Rails.root.join("public", invoice_pdf[:pdf_url])

	  if File.exist?(file_path)
	    send_file file_path, type: 'application/pdf', disposition: 'inline'
	  else
	    render json: { error: 'PDF not found' }, status: :not_found
	  end
	end


  private

  def shop_admin_or_he_admin?
    current_user.role.in?(%w[shop_admin he_admin])
  end
end
