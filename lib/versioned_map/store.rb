class VersionedMap
  class Store
    include Mongoid::Document
    include Mongoid::Timestamps
    include Mongoid::Versioning

    field :token, type: String

    before_create :set_token!

    def set_token!
      self.token = SecureRandom.hex(8)
    end

    def self.get(token)
      self.find_by(token: token)
    end
  end
end
