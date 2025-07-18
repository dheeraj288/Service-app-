module Api
  module V1
    class ShopsController < ApplicationController
      before_action :authorize_request
      before_action :authorize_he_admin

      def index
        shops = Shop.all
        render json: shops
      end

      def show
        shop = Shop.find(params[:id])
        render json: shop
      end

      def create
        shop = Shop.new(shop_params)
        if shop.save
          render json: shop, status: :created
        else
          render json: { errors: shop.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        shop = Shop.find(params[:id])
        if shop.update(shop_params)
          render json: shop
        else
          render json: { errors: shop.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        shop = Shop.find(params[:id])
        shop.destroy
        render json: { message: 'Shop deleted' }
      end

      private

      def shop_params
        params.require(:shop).permit(:name, :code)
      end

      def authorize_he_admin
        render json: { error: 'Forbidden' }, status: :forbidden unless @current_user.role == 'he_admin'
      end
    end
  end
end
