class TestController < ApplicationController
  def apis
    @facebook_api = current_user.graph_api if current_user
  end
end
