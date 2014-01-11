class Network
  class Storage
    include Mongoid::Document
    include Mongoid::Timestamps

    embedded_in :user, class_name: 'User'

    field :provider
    field :uid
    field :name
    field :oauth_token
    field :oauth_expires_at
    field :source
  end

  def initialize(auth)
    @provider = auth.provider
    @uid = auth.uid
    @name = auth.info.name
    @oauth_token = auth.credentials.token
    @oauth_expires_at = Time.at(auth.credentials.expires_at)
    @source = auth
  end

  def primary_key
    {uid: @uid}
  end

  def to_hash
    {provider: @provider, uid: @uid, name: @name, oauth_token: @oauth_token, oauth_expires_at: @oauth_expires_at}
  end

  def save!
    storage_collection.find(primary_key).upsert(primary_key.merge(to_hash))
  end

  private

  def storage_collection
    @storage_collection ||= Network::Storage.collection
  end

  def storage
    Storage.where(primary_key)
  end

  def self.from_storage(storage)
    new(storage.uid)
  end
end
