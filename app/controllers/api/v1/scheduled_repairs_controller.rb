class Api::V1::ScheduledRepairsController < ApplicationController
  before_action :authorize_request

  # Customer requests repair
  def create
    return unauthorized unless current_user.role == 'customer'

    repair = ScheduledRepair.new(repair_params)
    repair.customer = current_user
    repair.shop_id = current_user.shop_id
    repair.status = 'pending'

    if repair.save
      render json: { success: true, repair: repair }, status: :created
    else
      render json: { success: false, errors: repair.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # Shop Admin assigns a technician
  def assign_technician
    return unauthorized unless current_user.role == 'shop_admin'

    repair = ScheduledRepair.find(params[:id])
    repair.technician_id = params[:technician_id]
    repair.status = 'assigned'
    repair.save!

    render json: { success: true, repair: repair }
  end

  # Technician starts repair
  def start
    return unauthorized unless current_user.role == 'technician'

    repair = ScheduledRepair.find(params[:id])
    return forbidden unless repair.technician == current_user

    repair.update!(status: 'in_progress')
    render json: { success: true, repair: repair }
  end

  # Technician completes repair
  def complete
    return unauthorized unless current_user.role == 'technician'

    repair = ScheduledRepair.find(params[:id])
    return forbidden unless repair.technician == current_user

    repair.update!(status: 'completed')
    render json: { success: true, repair: repair }
  end

  private

  def repair_params
    params.require(:scheduled_repair).permit(:building_id, :elevator_id, :description, :scheduled_for)
  end

  def unauthorized
    render json: { error: 'Unauthorized' }, status: :unauthorized
  end

  def forbidden
    render json: { error: 'Forbidden' }, status: :forbidden
  end
end
