# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'onboard/version'

Gem::Specification.new do |spec|
  spec.name          = 'onboard'
  spec.version       = Onboard::VERSION
  spec.authors       = ['Nathaniel Hoag']
  spec.email         = ['info@nathanielhoag.com']
  spec.summary       = 'Automated Drupal contrib.'
  spec.description   = 'Checks, downloads, verifies, adds, and commits Drupal contrib modules.'
  spec.homepage      = 'https://github.com/nhoag/onboard'
  spec.bindir        = 'bin'
  spec.license       = 'MIT'
  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = ['onboard']
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']
  spec.add_dependency 'nokogiri', '~> 1.6'
  spec.add_dependency 'git', '~> 1.2'
  spec.add_dependency 'thor', ['>= 0.19.1', '< 2']
  spec.add_development_dependency 'bundler', '< 2'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec'
end
