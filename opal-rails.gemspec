# coding: utf-8
$:.push File.expand_path('../lib', __FILE__)
require 'opal-rails/version'

Gem::Specification.new do |s|
  s.name        = 'opal-rails'
  s.version     = Opal::Rails::VERSION
  s.authors     = ['Elia Schito']
  s.email       = ['perlelia@gmail.com']
  s.homepage    = ''
  s.summary     = %q{Rails bindings for opal JS engine}
  s.description = %q{Rails bindings for opal JS engine}

  s.rubyforge_project = 'opal-rails'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']
  
  s.add_dependency 'opal'
end
