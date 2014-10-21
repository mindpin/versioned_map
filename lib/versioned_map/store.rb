class VersionedMap
  class Store
    include Mongoid::Document
    include Mongoid::Timestamps::Created
    include Mongoid::Attributes::Dynamic

    field :token,   type: String
    field :version, type: Integer, default: 0

    embeds_many(:versions,
                class_name: self.name,
                cyclic:     true,
                inverse_of: :origin,
                validate:   false)

    embedded_in(:origin,
                class_name: self.name,
                cyclic:     true,
                inverse_of: :versions,
                validate:   false)

    before_create :set_token!

    def set_token!
      self.token = SecureRandom.hex(8) if !self.origin
    end

    def revise!
      raise UnpersistedEntity.new if self.new_record?

      attrs = attributes.clone

      parent = origin ? origin : self

      attrs.delete(:_id)
      attrs.delete(:versions)
      attrs.merge!(version:    parent.versions.size + 1,
                   origin:     parent,
                   created_at: Time.now)

      new = parent.versions.build

      new.unset("_id")
      new.unset("versions")
      new.update_attributes(attrs)
      new
    end

    def self.get(token)
      self.find_by(token: token)
    end
  end

  class UnpersistedEntity < Exception; end
end
