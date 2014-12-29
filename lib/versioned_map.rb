require "mongoid"
require "versioned_map/store"

class VersionedMap
  attr_accessor :store

  delegate :token, :id, to: :store

  def initialize(store = nil)
    self.store = store || Store.new
  end
  
  def self.find(token)
    vm = VersionedMap.new(Store.get(token))
    vm.latest
    vm
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
    !%w|versions version token _id created_at updated_at origin|.include?(key.to_s)
  end

  def save
    if store.new_record?
      return store.save && token
    end

    self.store = store.clone
    store.version  = 0
    store.versions = []
    store.origin   = nil
    store.save && token
  end

  def update
    self.store = store.revise!
  end

  def version
    store.version == 0 ? nil : store.version
  end

  def origin_store
    store.origin ? store.origin : store
  end

  def get_version(ver = 0)
    ver = !ver ? 0 : ver
    return if ver < 0
    return if ver > max_version

    if ver == 0
      self.store = origin_store.reload
      return self
    end

    self.store = origin_store.reload.versions.find_by(version: ver)
    self
  end

  def max_version
    origin_store.reload.versions.size
  end

  def latest
    get_version(max_version)
  end
end
