module NetworkHelper
  def callback_url(network)
    case network
      when :facebook
        # do nothing
      when :instagram
        "https://api.instagram.com/oauth/authorize/?client_id=#{ENV['INSTAGRAM_APP_ID']}&redirect_uri=#{app_url}/auth/instagram/callback&response_type=code"
      when :foursquare
        "https://foursquare.com/oauth2/authenticate/?client_id=#{ENV['FOURSQUARE_APP_ID']}&response_type=code&redirect_uri=#{app_url}/auth/foursquare/callback"
      else
        # do nothing
    end
  end
end
