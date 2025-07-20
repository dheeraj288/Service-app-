# app/controllers/api/v1/quotes_controller.rb
module Api::V1
  class QuotesController < ApplicationController
    before_action :authorize_request
    before_action :set_time_ticket, only: [:create]
    before_action :set_quote, only: [:show, :update, :approve, :reject]

    # POST /api/v1/time_tickets/:time_ticket_id/quotes
    # Shop Admin creates or updates quote
    def create
      return unauthorized unless current_user.role == 'shop_admin' && @time_ticket.service_request.shop_id == current_user.shop_id

      @quote = @time_ticket.build_quote(quote_params.merge(shop_admin: current_user, status: 'submitted'))

      if @quote.save
        render json: @quote, status: :created
      else
        render json: { errors: @quote.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # GET /api/v1/quotes/:id
    # Any role with access: shop_admin, he_admin, or ticket owner
    def show
      return unauthorized unless can_view_quote?(@quote)

      render json: @quote
    end

    # PATCH /api/v1/quotes/:id/update
    # Shop Admin can edit a draft or rejected quote
    def update
      return unauthorized unless current_user == @quote.shop_admin && @quote.status.in?(%w[draft rejected])

      if @quote.update(quote_params)
        render json: @quote
      else
        render json: { errors: @quote.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # PATCH /api/v1/quotes/:id/approve
    # HE Admin approves quote
    def approve
      return unauthorized unless current_user.role == 'he_admin'

      if @quote.update(status: 'approved')
        render json: @quote
      else
        render json: { errors: @quote.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # PATCH /api/v1/quotes/:id/reject
    # HE Admin rejects quote
    def reject
      return unauthorized unless current_user.role == 'he_admin'

      if @quote.update(status: 'rejected')
        render json: @quote
      else
        render json: { errors: @quote.errors.full_messages }, status: :unprocessable_entity
      end
    end

    private

    def set_time_ticket
      @time_ticket = TimeTicket.find(params[:time_ticket_id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'TimeTicket not found' }, status: :not_found
    end

    def set_quote
      @quote = Quote.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'Quote not found' }, status: :not_found
    end

    def quote_params
      params.require(:quote).permit(:description, :amount)
    end

    def can_view_quote?(quote)
      return true if current_user.role == 'he_admin'
      return true if current_user == quote.shop_admin
      return true if quote.time_ticket.technician == current_user
      return true if quote.time_ticket.service_request.customer == current_user
      false
    end

    def unauthorized
      render json: { error: 'Not authorized' }, status: :forbidden
    end
  end
end
