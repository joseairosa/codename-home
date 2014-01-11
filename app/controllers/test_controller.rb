class TestController < ApplicationController
  def apis
    @facebook_api = current_user.facebook_api if current_user
  end
end
