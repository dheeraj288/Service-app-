class Api::V1::TimeTicketsController < ApplicationController
  include ActionController::MimeResponds
  include ActionController::Helpers
  before_action :authorize_request
  before_action :set_time_ticket, only: [:approve, :reject]

  def create
    return unauthorized unless current_user.role == 'technician'

    ticket = TimeTicket.new(time_ticket_params)
    ticket.technician = current_user
    ticket.status = 'submitted'

    if ticket.save
      render json: { success: true, ticket: ticket }, status: :created
    else
      render json: { success: false, errors: ticket.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def shop_tickets
    return unauthorized unless current_user.role == 'shop_admin'

    tickets = TimeTicket
                .joins(:service_request)
                .where(service_requests: { shop_id: current_user.shop_id })
                .includes(:technician, :service_request)

    render json: tickets
  end

  def approve
    return unauthorized unless current_user.role == 'shop_admin'

    if @time_ticket.update(status: 'approved', approved_at: Time.current, approved_by: current_user.id)
      render json: { success: true, status: 'approved' }
    else
      render json: { success: false, errors: @time_ticket.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def reject
    return unauthorized unless current_user.role == 'shop_admin'

    if @time_ticket.update(
         status: 'rejected',
         rejected_at: Time.current,
         rejected_by: current_user.id,
         rejection_reason: params[:rejection_reason]
       )
      render json: { success: true, status: 'rejected', reason: @time_ticket.rejection_reason }
    else
      render json: { success: false, errors: @time_ticket.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def invoice_pdf
    @time_ticket = TimeTicket.find(params[:id])
    @technician = @time_ticket.technician
    @service_request = @time_ticket.service_request
    @customer = @service_request.customer

    respond_to do |format|
      format.pdf do
        render pdf: "invoice_#{@time_ticket.id}",
               template: "api/v1/time_tickets/invoice_pdf",
               formats: [:html],
               handlers: [:erb],
               disposition: 'inline', # or 'attachment' to force download
               encoding: 'UTF-8'
      end
    end
  end

  private

  def authorized_to_view_invoice?(ticket)
    return true if current_user.role == 'shop_admin' && ticket.service_request.shop_id == current_user.shop_id
    return true if current_user.role == 'technician' && ticket.technician_id == current_user.id
    false
  end

  def time_ticket_params
    params.require(:time_ticket).permit(:service_request_id, :start_time, :end_time, :notes)
  end

  def set_time_ticket
    @time_ticket = TimeTicket.find(params[:id])
  end

  def unauthorized
    render json: { error: 'Not authorized' }, status: :unauthorized
  end
end
