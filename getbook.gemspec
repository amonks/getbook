# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'getbook/version'

Gem::Specification.new do |spec|
  spec.name          = "getbook"
  spec.version       = Getbook::VERSION
  spec.authors       = ["Andrew Monks"]
  spec.email         = ["a@monks.co"]

  spec.summary       = %q{Download your data from Facebook and delete your account.}
  spec.homepage      = "http://github.com/amonks/getbook"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  # spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.executables   = ['getbook']
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.9"
  spec.add_development_dependency "rake", "~> 10.0"

  spec.add_runtime_dependency "capybara", "~> 2.4"
  spec.add_runtime_dependency "pry", "~> 0.10.1"
  spec.add_runtime_dependency "capybara-webkit", "~> 1.5"
  spec.add_runtime_dependency "nokogiri", "~>1.6"
end
