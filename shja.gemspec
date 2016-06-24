# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'shja/version'

Gem::Specification.new do |spec|
  spec.name          = "shja"
  spec.version       = Shja::VERSION
  spec.authors       = ["Iwaco"]
  spec.email         = ["iwaco@iwaco.pink"]

  spec.summary       = %q{TODO: Write a short summary, because Rubygems requires one.}
  spec.description   = %q{TODO: Write a longer description or delete this line.}
  spec.homepage      = "TODO: Put your gem's website or public repo URL here."
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "mechanize", "2.7.3"
  spec.add_dependency "nokogiri", "~> 1.4"
  spec.add_dependency "capybara", "2.7.1"
  spec.add_dependency "poltergeist", "1.9.0"
  spec.add_dependency "curb"
  spec.add_dependency "rubyzip", "1.1.7"
  spec.add_dependency "fastimage", "1.8.1"
  spec.add_dependency "memoist"
  spec.add_dependency "hashie"
  spec.add_dependency "speedpetal", "0.0.2"

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "mocha"
end
