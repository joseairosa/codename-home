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
