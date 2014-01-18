OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, ENV['FACEBOOK_APP_ID'], ENV['FACEBOOK_SECRET'], provider_ignores_state: true, scope: 'email,read_stream'
  provider :instagram, ENV['INSTAGRAM_APP_ID'], ENV['INSTAGRAM_SECRET'], provider_ignores_state: true
  provider :foursquare, ENV['FOURSQUARE_APP_ID'], ENV['FOURSQUARE_SECRET'], provider_ignores_state: true
end
