module Api
  module V1
    class AuthController < ApplicationController
      skip_before_action :authorize_request, only: [
        :shop_signup, :shop_login, :technician_login, :customer_signup, :customer_login, :refresh
      ]

      def shop_signup
        role = params.dig(:user, :role)

        unless %w[shop_admin he_admin].include?(role)
          return render json: { error: 'Only shop_admin and he_admin roles are allowed' }, status: :forbidden
        end

        user = nil
        ActiveRecord::Base.transaction do
          if role == 'shop_admin'
            shop = Shop.create!(name: params.dig(:user, :shop_name))
            user = build_user(role: role, shop_id: shop.id)
            user.save!
          else
            user = build_user(role: role)
            user.save!
          end
        end

        render_token_response(user, :created)

      rescue ActiveRecord::RecordInvalid => e
        render json: { error: e.message }, status: :unprocessable_entity
      end

      def shop_login
        login_user(role_scope: %w[shop_admin he_admin])
      end

      def technician_login
        login_user(role_scope: ['technician'])
      end

      def customer_signup
        user = nil

        ActiveRecord::Base.transaction do
          shop = Shop.find_by(code: params.dig(:user, :shop_code))
          raise ActiveRecord::RecordInvalid.new(Shop.new), 'Invalid shop code' unless shop

          user = build_user(role: 'customer', shop_id: shop.id)
          user.save!

          (params.dig(:user, :buildings) || []).each do |building_params|
            building = Building.create!(
              name: building_params[:name],
              address: building_params[:address],
              customer_id: user.id
            )

            (building_params[:elevators] || []).each do |elevator_params|
              Elevator.create!(
                identifier: elevator_params[:identifier],
                elevator_type: elevator_params[:elevator_type] || elevator_params[:type],
                status: elevator_params[:status],
                building_id: building.id
              )
            end
          end
        end

        render_token_response(user, :created)

      rescue ActiveRecord::RecordInvalid => e
        render json: { error: e.message }, status: :unprocessable_entity
      end

      def customer_login
        login_user(role_scope: ['customer'])
      end

      def refresh
        token = request.headers['Authorization']&.split(' ')&.last
        decoded = JsonWebToken.decode(token)

        if decoded&.dig('user_id') && decoded['refresh']
          user = User.find_by(id: decoded['user_id'])
          access_token = JsonWebToken.encode({ user_id: user.id }, 15.minutes.from_now)
          render json: { access_token: access_token }, status: :ok
        else
          render json: { error: 'Invalid refresh token' }, status: :unauthorized
        end
      end

      def logout
        render json: { message: 'Logged out. Please discard token on client.' }, status: :ok
      end

      private

      def user_params
        params.require(:user).permit(
          :name, :email, :password, :password_confirmation, :phone,
          :address, :role, :profile_image_url, :shop_id, :shop_code, :shop_name,
          buildings: [
            :name, :address,
            elevators: [:identifier, :elevator_type, :type, :status]
          ]
        )
      end

      def build_user(role:, shop_id: nil)
        attrs = user_params.except(:shop_code, :buildings, :shop_name).merge(role: role)
        attrs[:shop_id] = shop_id if shop_id
        User.new(attrs)
      end

      def render_token_response(user, status)
        tokens = generate_tokens(user.id)
        render json: {
          access_token: tokens[:access_token],
          refresh_token: tokens[:refresh_token],
          user: user.as_json(
            except: [:password_digest],
            include: {
              buildings: {
                include: :elevators
              }
            }
          )
        }, status: status
      end

      def generate_tokens(user_id)
        {
          access_token: JsonWebToken.encode({ user_id: user_id }, 15.minutes.from_now),
          refresh_token: JsonWebToken.encode({ user_id: user_id, refresh: true }, 7.days.from_now)
        }
      end

      def login_user(role_scope:)
        email = params.dig(:user, :email)
        password = params.dig(:user, :password)

        user = User.find_by(email: email)
        if user&.authenticate(password) && role_scope.include?(user.role)
          render_token_response(user, :ok)
        else
          render json: { error: 'Invalid credentials or unauthorized role' }, status: :unauthorized
        end
      end
    end
  end
end
