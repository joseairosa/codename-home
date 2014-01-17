class UserFriendsRank
  attr_accessor :network, :user

  attr_reader :ranks, :feed_data, :like_data

  SCORE_WEIGHTS = {
    with_tags:    5,
    message_tags: 1.7,
    story_tags:   1.5,
    from:         1,
    like_photo:   5,
    like_album:   2.5,
    like_link:    1,
    like_video:   1,
    like_status:  10,
    like_checkin: 5,
    like_comment: 2.5
  }

  def initialize(user, network)
    @user, @network = user, network
    @ranks, @feed_data = {}, []
  end

  def generate_feed_data
    pages = 20
    per_page = 25
    Rails.logger.debug "Generating data for #{pages*per_page} entries on user feed..."
    current_page = @user.facebook_api.get_connections('me','feed', fields: 'id,story_tags,status_type,from,comments,type,message_tags', limit: per_page)
    pages.times do |page|
      Rails.logger.debug "Getting page #{page+1}..."
      @feed_data += current_page
      current_page = current_page.next_page
    end
    nil
  end

  def generate_likes_data
    Rails.logger.debug "Generating data for user likes..."
    query_hash = {}
    pages = 1
    per_page = 5000
    pages.times do |page|
      Rails.logger.debug "Getting page #{page+1}..."
      %w(photo album link video status checkin comment).each do |data|
        case data
          when 'photo', 'album'
            owner_id = 'owner'
            object_id = 'object_id'
          when 'comment'
            owner_id = 'fromid'
            object_id = 'object_id'
          when 'link'
            owner_id = 'owner'
            object_id = 'link_id'
          when 'video'
            owner_id = 'owner'
            object_id = 'vid'
          when 'checkin'
            owner_id = 'author_uid'
            object_id = 'checkin_id'
          else
            owner_id = 'uid'
            object_id = "#{data}_id"
        end

        query_hash["#{data}_#{page}".to_sym] = "SELECT uid, name FROM user WHERE uid IN (SELECT #{owner_id} FROM #{data} WHERE #{object_id} IN (SELECT object_id FROM like WHERE user_id = me() AND object_type = '#{data}' LIMIT #{100*page},#{per_page}))"
      end
    end
    ap query_hash
    @like_data = @user.facebook_api.fql_multiquery(query_hash)
  end

  def reset_ranks
    @ranks = {}
  end

  def generate_ranks
    @feed_data.each do |entry_hash|
      Rails.logger.debug "Processing a #{entry_hash['type']} (#{entry_hash['id']})..."
      rank_story_tags(entry_hash)
      rank_message_tags(entry_hash)
      rank_with_tags(entry_hash)
      rank_from(entry_hash)
    end
    rank_likes
    nil
  end

  def sorted_ranks
    Hash[@ranks.sort_by{ |_, v| -v[:score] }]
  end

  private

  def rank_likes
    @like_data.each do |query, data|
      data.each do |user_hash|
        set_rank("like_#{query.split('_').first}".to_sym, user_hash['uid'], user_hash['name'])
      end
    end
  end

  def rank_story_tags(user_hash)
    if user_hash['story_tags']
      user_hash['story_tags'].each do |_, story_tags_hash|
        story_tags_hash.each do |user|
          set_rank(:story_tags, user['id'], user['name'])
        end
      end
    end
  end

  def rank_message_tags(user_hash)
    if user_hash['message_tags']
      user_hash['message_tags'].each do |_, message_tags_hash|
        message_tags_hash.each do |user|
          set_rank(:message_tags, user['id'], user['name'])
        end
      end
    end
  end

  def rank_with_tags(user_hash)
    if user_hash['with_tags']
      user_hash['with_tags']['data'].each do |user|
        set_rank(:with_tags, user['id'], user['name'])
      end
    end
  end

  def rank_from(user_hash)
    if user_hash['from']
      set_rank(:from, user_hash['from']['id'], user_hash['from']['name'])
    end
  end

  def set_rank(score, uid, name=nil)
    if uid != @user.facebook.uid
      @ranks[uid.to_s] ||= { uid: uid.to_s, name: name, score: 0 }
      @ranks[uid.to_s][:score] += 1*SCORE_WEIGHTS[score]
      Rails.logger.debug "Added #{1*SCORE_WEIGHTS[score]} to score '#{score}' for user #{name} (#{uid}). New total: #{@ranks[uid.to_s][:score]}."
    end
  end

end