module Api
  module V1
    class UsersController < ApplicationController
      before_action :authorize_request
      before_action :set_user, only: [:update, :destroy]
      before_action :require_shop_admin!, only: [:index, :destroy]

      def profile
        render json: current_user.as_json(except: [:password_digest])
      end

      def index
        users = User.where(shop_id: params[:shop_id])
        render json: users.as_json(except: [:password_digest])
      end

      def update
        if @user.update(user_params)
          render json: @user.as_json(except: [:password_digest])
        else
          render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @user.destroy
        render json: { message: 'User deleted successfully' }
      end

      private

      def set_user
        @user = User.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'User not found' }, status: :not_found
      end

      def user_params
        params.require(:user).permit(
          :name, :email, :password, :password_confirmation,
          :phone, :address, :role, :profile_image_url, :shop_id, :shop_code,
          buildings: [
            :name, :address,
            elevators: [:identifier, :elevator_type, :status]
          ]
        )
      end

    end
  end
end
