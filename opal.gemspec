# -*- encoding: utf-8 -*-
require File.expand_path('../lib/opal/version', __FILE__)

Gem::Specification.new do |s|
  s.name         = 'opal'
  s.version      = Opal::VERSION
  s.author       = 'Adam Beynon'
  s.email        = 'adam@adambeynon.com'
  s.homepage     = 'http://opalrb.org'
  s.summary      = 'Ruby runtime and core library for javascript'
  s.description  = 'Ruby runtime and core library for javascript.'

  s.files          = `git ls-files`.split("\n")
  s.executables    = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.test_files     = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths  = ['lib']
  
  s.add_development_dependency 'rspec', '~> 2.10'
end