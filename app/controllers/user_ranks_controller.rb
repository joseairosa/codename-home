class UserRanksController < ApplicationController
  def index
    @ranked_users = UserFriendsRank.new(current_user, :facebook, params['user_ranks']).sorted_ranks.first(12)
    respond_to do |format|
      format.js
    end
  end
end
