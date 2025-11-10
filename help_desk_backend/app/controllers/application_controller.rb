class ApplicationController < ActionController::API
  include ActionController::Cookies

  # Skip CSRF protection for API-only mode while keeping cookies enabled
  # Note: For API-only apps, we rely on JWT tokens and CORS instead of CSRF tokens
end
