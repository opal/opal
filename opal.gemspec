# coding: utf-8
$:.push File.expand_path('../lib', __FILE__)
require 'opal/version'

Gem::Specification.new do |s|
  s.name         = 'opal'
  s.version      = Opal::VERSION
  s.authors      = ['Adam Beynon']
  s.email        = ['adam@adambeynon.com']
  s.homepage     = 'http://opalscript.org'
  s.summary      = 'Ruby runtime and core library for javascript'
  s.description  = 'Ruby runtime and core library for javascript.'

  s.files         = `git ls-files`.split("\n") + %w[opal.js opal-parser.js]
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ['lib']

  s.add_development_dependency 'rake'
  s.add_development_dependency 'racc'
end

