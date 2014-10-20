require "mongoid"
require "mongoid/versioning"
require "securerandom"
require "versioned_map/store"

class VersionedMap
  attr_accessor :store

  delegate :token, :id, to: :store

  def initialize(store = nil)
    self.store = store || Store.new
  end
  
  def self.find(token)
    VersionedMap.new(Store.get(token))
  end

  def set(key, value = "")
    return false if !validate_key(key)

    store[key] = value
  end

  def get(key)
    return false if !validate_key(key)

    store[key]
  end

  def remove(key)
    return false if !validate_key(key)

    store[key] = nil
  end

  def validate_key(key)
    [String, Symbol].include?(key.class) &&
    !%w|versions version token _id created_at updated_at|.include?(key.to_s)
  end

  def save
    if store.new_record?
      return store.save && token
    end

    self.store = store.versionless(&:clone)
    store.version  = 1
    store.versions = []
    store.save && token
  end

  def update
    store.revise!
  end

  def version
    ver = store.version - 1
    ver == 0 ? nil : ver
  end

  def get_version(ver = 0)
    ver = !ver ? 0 : ver
    return if ver > max_version
    VersionedMap.new(store.versions[ver])
  end

  def max_version
    store.versions.size - 1
  end
end
