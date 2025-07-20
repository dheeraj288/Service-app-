# app/controllers/api/v1/preventive_maintenances_controller.rb
module Api::V1
  class PreventiveMaintenancesController < ApplicationController
    before_action :authorize_request
    before_action :set_pm, only: [ :assign_technician, :complete, :cancel]

    # SHOP ADMIN: create PM order
    # POST /api/v1/preventive_maintenances
    def create
      return forbidden unless current_user.role == 'shop_admin'

      pm = PreventiveMaintenance.new(pm_params)
      pm.shop = current_user.shop
      pm.customer_id = pm_params[:customer_id]
      pm.status = 'scheduled'
      pm.next_run_date = pm.schedule_date

      if pm.save
        render json: pm, status: :created
      else
        render json: { errors: pm.errors.full_messages }, status: :unprocessable_entity
      end
    end

   
    def index
      if current_user.role == 'shop_admin'
        pms = PreventiveMaintenance.where(shop: current_user.shop)
      elsif current_user.role == 'technician'
        pms = PreventiveMaintenance.where(technician: current_user)
      else
        return forbidden
      end

      render json: pms
    end

    # GET /api/v1/preventive_maintenances/my
    # CUSTOMER: list their PMs
    def my
      return forbidden unless current_user.role == 'customer'

      pms = current_user.preventive_maintenances_as_customer
      render json: pms
    end

    # ASSIGN TECHNICIAN
    # PATCH /api/v1/preventive_maintenances/:id/assign
    def assign_technician
      return forbidden unless current_user.role == 'shop_admin'
      tech = User.find_by(id: params[:technician_id], role: 'technician', shop: current_user.shop)
      return render json: { error: 'Technician not found' }, status: :unprocessable_entity if tech.nil?

      @pm.update!(technician: tech)
      render json: @pm
    end

    # TECHNICIAN: mark completed
    # PATCH /api/v1/preventive_maintenances/:id/complete
    def complete
      return forbidden unless current_user.role == 'technician' && @pm.technician == current_user

      @pm.mark_completed!
      render json: @pm
    end

    # CANCEL PM
    # PATCH /api/v1/preventive_maintenances/:id/cancel
    def cancel
      return forbidden unless current_user.role.in?(%w[shop_admin he_admin])

      @pm.update!(status: 'cancelled')
      render json: @pm
    end

    private

    def pm_params
      params.require(:preventive_maintenance).permit(:customer_id, :schedule_date, :frequency)
    end

    def set_pm
      @pm = PreventiveMaintenance.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'PM order not found' }, status: :not_found
    end

    def forbidden
      render json: { error: 'Forbidden' }, status: :forbidden
    end
  end
end
