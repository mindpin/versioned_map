require "spec_helper"

describe VersionedMap do
  it {
    map0 = VersionedMap.new

    token0 = map0.store!.token
    expect(map0.token).to eq token0
    expect(map0.current_version).to eq nil

    map1 = map0.store!
    token1 = map1.token
    expect(map1.token).to eq token1
    expect(map1.current_version).to eq nil

    expect(token0).to_not eq token1
    expect(map0.id).to_not eq map1.id

    map1.update
    expect(map1.current_version).to eq 1
    expect(map1.token).to eq token1

    map1.update
    expect(map1.current_version).to eq 2
    expect(map1.token).to eq token1
    expect(map1.max_version).to eq 1

    map2 = map0.store!
    token2 = map2.token
    expect(map2.token).to eq token2
    expect(map2.current_version).to eq nil

    map2.set("foo", "bar")
    expect(map2.get("foo")).to eq "bar"

    map2.remove("foo")
    expect(map2.get("foo")).to eq nil

    expect(VersionedMap.get(token0)).to eq map0
    expect(VersionedMap.get(token1)).to eq map1
    expect(VersionedMap.get(token2)).to eq map2
  }
end
