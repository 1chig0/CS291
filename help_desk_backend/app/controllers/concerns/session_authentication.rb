module SessionAuthentication
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_with_session, except: [:register, :login]
  end

  private

  def authenticate_with_session
    user_id = session[:user_id]

    unless user_id
      render json: { error: 'No session found' }, status: :unauthorized
      return
    end

    @current_user = User.find_by(id: user_id)

    unless @current_user
      render json: { error: 'No session found' }, status: :unauthorized
      return
    end

    @current_user.update_last_active!
  end

  def current_user
    @current_user
  end
end

