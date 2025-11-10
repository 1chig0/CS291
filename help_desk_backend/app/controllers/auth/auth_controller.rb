module Auth
  class AuthController < ApplicationController
    include SessionAuthentication

    skip_before_action :authenticate_with_session, only: [:register, :login]

    def register
      user = User.new(user_params)

      if user.save
        session[:user_id] = user.id
        token = JwtService.encode(user)

        render json: {
          user: user_response(user),
          token: token
        }, status: :created
      else
        render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def login
      user = User.find_by(username: params[:username])

      if user&.authenticate(params[:password])
        session[:user_id] = user.id
        user.update_last_active!
        token = JwtService.encode(user)

        render json: {
          user: user_response(user),
          token: token
        }, status: :ok
      else
        render json: { error: 'Invalid username or password' }, status: :unauthorized
      end
    end

    def logout
      reset_session
      render json: { message: 'Logged out successfully' }, status: :ok
    end

    def refresh
      # This endpoint only works with session, not JWT
      # So authenticate_with_session will handle the authentication
      token = JwtService.encode(current_user)

      render json: {
        user: user_response(current_user),
        token: token
      }, status: :ok
    end

    def me
      render json: user_response(current_user), status: :ok
    end

    private

    def user_params
      params.permit(:username, :password)
    end

    def user_response(user)
      {
        id: user.id,
        username: user.username,
        created_at: user.created_at.iso8601,
        last_active_at: user.last_active_at&.iso8601
      }
    end
  end
end

