
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "eblocker/async/redis/version"

Gem::Specification.new do |spec|
  spec.name          = "eblocker-async-redis"
  spec.version       = Eblocker::Async::Redis::VERSION
  spec.authors       = ["eBlocker Open Source UG"]
  spec.email         = ["dev@eblocker.org"]

  spec.summary       = %q{async-io based redis connection}
  spec.description   = %q{async-io based redis connection}
  spec.homepage      = "https://github.com/eblocker/eblocker-async-redis"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = ""
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "async-io", "~> 1.0"
  spec.add_dependency "redis", "~> 3.2"

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"

end
