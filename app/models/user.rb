class User
  include Mongoid::Document
  include Mongoid::Timestamps

  field :email

  index({'facebook.uid' => 1}, {unique: true})

  index({email: 1}, {sparse: true, unique: true})

  embeds_one :facebook, class_name: 'Accounts::Facebook::Storage'

  alias_method :link_facebook, :create_facebook

  def self.create_or_retrieve(auth)
    if auth.respond_to?(:uid)
      storage = self.where({'facebook.uid' => auth.uid}).first
      if storage.nil?
        new_user = self.create
        new_user.link_facebook(
            {provider: auth.provider,
             uid: auth.uid,
             name: auth.info.name,
             oauth_token: auth.credentials.token,
             oauth_expires_at: Time.at(auth.credentials.expires_at)}
        )
      end
      storage
    end
  end
end
