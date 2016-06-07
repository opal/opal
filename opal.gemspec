# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'opal/version'

Gem::Specification.new do |s|
  s.name         = 'opal'
  s.version      = Opal::VERSION
  s.author       = 'Adam Beynon'
  s.email        = 'adam.beynon@gmail.com'
  s.homepage     = 'http://opalrb.org'
  s.summary      = 'Ruby runtime and core library for JavaScript'
  s.description  = 'Ruby runtime and core library for JavaScript.'
  s.license      = 'MIT'

  s.files         = `git ls-files`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ['lib']

  s.required_ruby_version = '>= 1.9.3'

  s.add_dependency 'sourcemap', '~> 0.1.0'
  s.add_dependency 'sprockets', '~> 3.1'
  s.add_dependency 'hike', '~> 1.2'
  s.add_dependency 'tilt', '>= 1.4'
  s.add_dependency 'ast', '>= 2.3.0'
  s.add_dependency 'parser', '>= 2.3.1.2'

  s.add_development_dependency 'mspec', '1.5.20'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'racc'
  s.add_development_dependency 'rspec', '~> 2.99'
  s.add_development_dependency 'octokit', '~> 2.4.0'
  s.add_development_dependency 'bundler', '~> 1.5'
  s.add_development_dependency 'yard', '~> 0.8.7'
  s.add_development_dependency 'rack-test'
  s.add_development_dependency 'opal-minitest'
  s.add_development_dependency 'coveralls'
end
