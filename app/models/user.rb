class User
  include Mongoid::Document
  include Mongoid::Timestamps

  field :email

  index({'network.uid' => 1})

  index({email: 1}, {sparse: true, unique: true})

  embeds_many :networks, class_name: 'Network::Storage'

  def self.create_or_retrieve(uid, auth)
    user = self.find_by_account(auth.provider, auth.uid)
    unless user
      user = self.where(id: uid).first
      user = self.create! unless user
      user.link_account(auth)
    end
    user
  end

  def self.find_by_account(provider, uid)
    self.where({'networks.provider' => provider, 'networks.uid' => uid}).first
  end

  def link_account(auth)
    if auth.respond_to?(:uid)
      if auth.credentials.expires_at
        oauth_expires_at = Time.at(auth.credentials.expires_at)
      else
        oauth_expires_at = nil
      end
      networks.create!({
        provider: auth.provider,
        uid: auth.uid,
        name: auth.info.name,
        oauth_token: auth.credentials.token,
        oauth_expires_at: oauth_expires_at,
        source: auth
      })
    end
  end

  def facebook
    find_network :facebook
  end

  def facebook_api
    @facebook_api ||= Koala::Facebook::API.new(facebook.oauth_token) if has_network? :facebook
  end

  def instagram
    find_network :instagram
  end

  def instagram_api
    @instagram_api ||= Instagram.client(:access_token => instagram.oauth_token) if has_network? :instagram
  end

  def has_network?(network)
    !!send(network.to_sym)
  end

  def find_network(network)
    networks.where(provider: network.to_s).first
  end
end
