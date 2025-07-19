module Api
  module V1
    class AuthController < ApplicationController
      skip_before_action :authorize_request, only: [
        :shop_signup, :shop_login, :technician_signup, :technician_login,
        :customer_signup, :customer_login, :refresh
      ]

      def shop_signup
        ActiveRecord::Base.transaction do
          shop = Shop.create!(name: params[:user][:shop_name])
          user = User.new(user_params.merge(role: 'shop_admin', shop_id: shop.id))

          if user.save
            render_token_response(user, :created)
          else
            raise ActiveRecord::Rollback
          end
        end
      rescue ActiveRecord::RecordInvalid => e
        render json: { error: e.message }, status: :unprocessable_entity
      end

      def shop_login
        login_user(role_scope: %w[he_admin shop_admin])
      end

      def technician_signup
        user = User.new(user_params.merge(role: 'technician'))
        if user.save
          render_token_response(user, :created)
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def technician_login
        login_user(role_scope: ['technician'])
      end

      def customer_signup
        shop = Shop.find_by(code: params[:user][:shop_code])
        return render json: { error: 'Invalid shop code' }, status: :unprocessable_entity unless shop

        user = User.new(user_params.merge(role: 'customer', shop_id: shop.id))
        if user.save
          render_token_response(user, :created)
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
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
          :name, :email, :password, :password_confirmation,
          :phone, :address, :profile_image_url, :shop_id, :shop_code, :shop_name
        )
      end

      def render_token_response(user, status)
        tokens = generate_tokens(user.id)
        render json: {
          access_token: tokens[:access_token],
          refresh_token: tokens[:refresh_token],
          user: user.as_json(except: [:password_digest])
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
