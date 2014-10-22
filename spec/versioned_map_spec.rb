require "spec_helper"

describe VersionedMap do
  it {
    map = VersionedMap.new

    token0 = map.save
    expect(map.token).to eq token0
    expect(map.version).to eq nil

    id0 = map.id
    token1 = map.save
    expect(map.token).to eq token1
    expect(map.version).to eq nil

    expect(token0).to_not eq token1
    expect(map.id).to_not eq id0

    map.update
    expect(map.version).to eq 1
    expect(map.token).to eq token1

    map.update
    expect(map.version).to eq 2
    expect(map.token).to eq token1
    expect(map.max_version).to eq 2
    expect(map.get_version(1).version).to eq 1

    map.set("foo", "bar")
    expect(map.get("foo")).to eq "bar"

    token2 = map.save
    expect(map.get("foo")).to eq "bar"
    expect(map.token).to eq token2
    expect(map.version).to eq nil

    map.set("foo", "bag")
    map.update
    expect(map.get("foo")).to eq "bag"
    expect(map.get_version(0).get("foo")).to eq "bar"

    map.set("foo", "bar")
    map.remove("foo")
    map.update
    expect(map.get("foo")).to eq nil
    expect(map.get_version(0).get("foo")).to eq "bar"
    expect(map.get_version(1).get("foo")).to eq "bag"

    expect(VersionedMap.find(token2).store).to eq map.store
  }
end
