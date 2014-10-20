require "mongoid"
require "mongoid/versioning"
require "securerandom"

class VersionedMap
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Versioning

  field :token, type: String

  before_create    :set_token!

  def set(key, value = "")
    return false if ![String, Symbol].include?(key.class)
    return false if %w|token _id created_at updated_at|.include?(key.to_s)

    self[key] = value
  end

  def get(key)
    return false if ![String, Symbol].include?(key.class)
    return false if %w|token _id created_at updated_at|.include?(key.to_s)

    self[key]
  end

  def remove(key)
    self.unset(key)
  end

  def store!
    if self.new_record?
      return self.save && self
    end

    self.versionless do |doc|
      new = doc.clone
      new.set_token!
      new.save && new
    end
  end

  def update
    self.revise!
  end

  def current_version
    ver = version - 1
    ver== 0 ? nil : ver
  end

  def get_version(ver = 0)
    ver = ver.nil? ? 0 : ver
    self.versions[ver]
  end

  def latest
    self.versions.last
  end

  def max_version
    self.latest.current_version
  end

  def set_token!
    self.token = SecureRandom.hex(8)
  end

  def self.get(token)
    self.find_by(token: token)
  end
end
