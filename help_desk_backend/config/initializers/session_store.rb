# Be sure to restart your server when you modify this file.

Rails.application.config.session_store :active_record_store,
  key: '_help_desk_session',
  same_site: Rails.env.development? ? :lax : :none,
  secure: Rails.env.production?,
  httponly: true

