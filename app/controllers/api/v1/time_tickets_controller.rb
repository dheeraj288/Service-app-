class Api::V1::TimeTicketsController < ApplicationController
  before_action :authorize_request
  before_action :set_time_ticket, only: [:approve]

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

    @time_ticket.update!(
      status: 'approved',
      approved_at: Time.current,
      approved_by: current_user.id
    )

    render json: { success: true, status: 'approved' }
  end

  private

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
