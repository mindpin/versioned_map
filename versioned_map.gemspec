# coding: utf-8
lib = File.expand_path("./lib/versioned_map", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "./lib/version"

Gem::Specification.new do |spec|
  spec.name          = "versioned_map"
  spec.version       = VersionedMap::VERSION
  spec.authors       = ["Kaid"]
  spec.email         = ["kaid@kaid.me"]
  spec.summary       = %q{Multi-version document store.}
  spec.description   = %q{Multi-version document store. Fundamental tool to build varials anonymous online services.}
  spec.homepage      = "https://github.com/mindpin/versioned_map"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "mongoid", "~> 4.0.0"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.1.0"
  spec.add_development_dependency "pry"
end
