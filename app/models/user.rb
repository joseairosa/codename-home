class User
  include Mongoid::Document
  include Mongoid::Timestamps

  field :email

  index({'facebook.uid' => 1}, {unique: true})
  index({'instagram.uid' => 1}, {unique: true})

  index({email: 1}, {sparse: true, unique: true})

  embeds_one :facebook, class_name: 'Accounts::Facebook::Storage'
  embeds_one :instagram, class_name: 'Accounts::Instagram::Storage'

  def self.create_or_retrieve(uid, auth)
    case auth.provider
      when 'facebook'
        user = self.find_by_facebook_uid(auth.uid)
        unless user
          user = self.find_or_create_by(id: uid)
          user.link_facebook(auth)
        end
        #signed_in_user.link_facebook(auth) unless signed_in_user.facebook
        #
        #unless facebook_user
        #  signed_in_user.link_facebook(auth) unless user.facebook
        #end
        #signed_in_user = self.find_or_create_by(id: uid)
        #user.link_facebook(auth) unless user.facebook
      when 'instagram'
        user = self.find_by_instagram_uid(auth.uid)
        unless user
          user = self.find_or_create_by(id: uid)
          user.link_instagram(auth)
        end
        #user.link_instagram(auth) unless user.instagram
      when 'foursquare'
      else
        # do nothing
    end
    user
  end

  def self.find_by_facebook_uid(uid)
    self.where({'facebook.uid' => uid}).first
  end

  def self.find_by_instagram_uid(uid)
    self.where({'instagram.uid' => uid}).first
  end

  def link_facebook(auth)
    if auth.respond_to?(:uid)
      create_facebook(
          {provider: auth.provider,
           uid: auth.uid,
           name: auth.info.name,
           oauth_token: auth.credentials.token,
           oauth_expires_at: Time.at(auth.credentials.expires_at)}
      )
    end
  end

  def link_instagram(auth)
    if auth.respond_to?(:uid)
      create_instagram(
          {provider: auth.provider,
           uid: auth.uid,
           name: auth.info.name,
           oauth_token: auth.credentials.token,
           oauth_expires_at: nil}
      )
    end
  end

  def graph_api
    @graph_api ||= Koala::Facebook::API.new(facebook.oauth_token) if facebook
  end
end
