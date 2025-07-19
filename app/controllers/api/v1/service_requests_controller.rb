class Api::V1::ServiceRequestsController < ApplicationController
  before_action :authorize_request
  before_action :set_service_request, only: [:destroy, :assign_technician, :resolve]

  before_action :authorize_customer!,     only: [:create, :my_requests]
  before_action :authorize_shop_admin!,   only: [:assign_technician, :shop_requests]
  before_action :authorize_technician!,   only: [:resolve]

  # ─────────────── Customer ───────────────

  # POST /api/v1/service_requests
  def create
    request = current_user.created_service_requests.build(service_request_params)
    request.shop_id = current_user.shop_id
    request.status = 'pending'

    if request.save
      render json: { success: true, request: request }, status: :created
    else
      render json: { success: false, errors: request.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # GET /api/v1/service_requests/my_requests
  def my_requests
    requests = current_user.created_service_requests.order(created_at: :desc)
    render json: { success: true, requests: requests }
  end

  # DELETE /api/v1/service_requests/:id
  def destroy
    if current_user.customer? && @service_request.customer_id != current_user.id
      return render json: { error: 'Not authorized to delete this request' }, status: :unauthorized
    end

    @service_request.destroy
    render json: { success: true, message: 'Request deleted successfully' }
  end

  # ─────────────── Shop Admin ───────────────

  # GET /api/v1/service_requests/shop_requests
  def shop_requests
    debugger
    requests = ServiceRequest.where(shop_id: current_user.shop_id)
                             .includes(:customer, :technician)
                             .order(created_at: :desc)
    render json: { success: true, requests: requests }
  end

  # PUT /api/v1/service_requests/:id/assign_technician
  def assign_technician
    technician = User.find_by(
      id: params[:technician_id],
      role: 'technician',
      shop_id: current_user.shop_id
    )

    if technician.nil?
      return render json: { error: 'Technician not found or not in your shop' }, status: :unprocessable_entity
    end

    if @service_request.update(
      technician_id: technician.id,
      eta: params[:eta],
      assigned_at: Time.current,
      status: 'assigned'
    )
      render json: { success: true, service_request: @service_request }
    else
      render json: { error: 'Failed to assign technician', details: @service_request.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # ─────────────── Technician ───────────────

  # PUT /api/v1/service_requests/:id/resolve
  def resolve
    unless @service_request.technician_id == current_user.id
      return render json: { error: 'Not authorized to resolve this request' }, status: :forbidden
    end

    if @service_request.update(status: 'resolved')
      render json: { success: true, message: 'Request resolved successfully' }
    else
      render json: { error: 'Failed to resolve request', details: @service_request.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # ─────────────── Private ───────────────

  private

  def set_service_request
    @service_request = ServiceRequest.find_by(id: params[:id])
    render(json: { error: 'Service request not found' }, status: :not_found) unless @service_request
  end

  def service_request_params
    params.require(:service_request).permit(:title, :description)
  end

  def authorize_customer!
    render json: { error: 'Only customers can perform this action' }, status: :unauthorized unless current_user.customer?
  end

  def authorize_shop_admin!
    render json: { error: 'Only shop admins can perform this action' }, status: :unauthorized unless current_user.shop_admin?
  end

  def authorize_technician!
    render json: { error: 'Only technicians can perform this action' }, status: :unauthorized unless current_user.technician?
  end
end
