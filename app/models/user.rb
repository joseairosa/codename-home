class User
  include Mongoid::Document
  include Mongoid::Timestamps

  field :email

  index({'facebook.uid' => 1}, {unique: true})

  index({email: 1}, {sparse: true, unique: true})

  embeds_one :facebook, class_name: 'Accounts::Facebook::Storage'

  def self.create_or_retrieve(auth)
    user = self.find_by_facebook_uid(auth.uid)
    if user.nil?
      user = self.create
      user.link_facebook(auth)
    end
    user
  end

  def self.find_by_facebook_uid(uid)
    self.where({'facebook.uid' => uid}).first
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
end
