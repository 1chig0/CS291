module JwtAuthentication
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_with_jwt
  end

  private

  def authenticate_with_jwt
    token = extract_token_from_header

    unless token
      render json: { error: 'No token provided' }, status: :unauthorized
      return
    end

    decoded = JwtService.decode(token)

    unless decoded
      render json: { error: 'Invalid token' }, status: :unauthorized
      return
    end

    @current_user = User.find_by(id: decoded[:user_id])

    unless @current_user
      render json: { error: 'User not found' }, status: :unauthorized
      return
    end

    @current_user.update_last_active!
  end

  def extract_token_from_header
    auth_header = request.headers['Authorization']
    return nil unless auth_header

    auth_header.split(' ').last if auth_header.start_with?('Bearer ')
  end

  def current_user
    @current_user
  end
end

