# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'moac_eth/version'

Gem::Specification.new do |spec|
  spec.name          = "moac_eth"
  spec.version       = MoacEth::VERSION
  spec.authors       = ["Kwin Song"]
  spec.email         = ["songkuoyin@gmail.com"]

  spec.summary       = %q{Simple API to sign Ethereum transactions.}
  spec.description   = %q{Library to build, parse, and sign Ethereum transactions.}
  spec.homepage      = "https://github.com/songky/ruby-moac"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'digest-sha3', '~> 1.1'
  spec.add_dependency 'ffi', '~> 1.0'
  spec.add_dependency 'money-tree', '~> 0.9'
  spec.add_dependency 'rlp', '~> 0.7.3'
  spec.add_dependency 'scrypt', '~> 3.0.5'

  spec.add_development_dependency 'bundler', '~> 1.12'
  spec.add_development_dependency 'pry', '~> 0.1'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
