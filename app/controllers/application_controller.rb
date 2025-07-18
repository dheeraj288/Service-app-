class ApplicationController < ActionController::API
  before_action :authorize_request

  attr_reader :current_user

  private

  def authorize_request
    token = request.headers['token']&.split(' ')&.last
    decoded = JsonWebToken.decode(token)

    if decoded && (user = User.find_by(id: decoded['user_id']))
      @current_user = user
    else
      render_unauthorized
    end
  end

  def render_unauthorized
    render json: { error: 'Unauthorized' }, status: :unauthorized
  end

  def require_shop_admin!
    render_unauthorized unless current_user&.shop_admin?
  end
end
