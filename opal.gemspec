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
  s.summary      = 'Ruby runtime and core library for javascript'
  s.description  = 'Ruby runtime and core library for javascript.'
  s.license      = 'MIT'

  s.files          = `git ls-files`.split("\n")
  s.executables    = ['opal']
  s.test_files     = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths  = ['lib']

  s.add_dependency 'source_map'

  s.add_development_dependency 'mspec', '1.5.20'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'racc'
  s.add_development_dependency 'opal-sprockets', '~> 0.3.0'
  s.add_development_dependency 'rspec', '~> 2.14'
  s.add_development_dependency 'octokit', '~> 2.4.0'
end
