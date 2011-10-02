# coding: utf-8
$:.push File.expand_path('../lib', __FILE__)
require 'opal/version'

# if we are building gem ready to publish, then ensure opal.js and
# opal-parser.js exist - if they dont then our gem will crash out
# compalining they are not there.
unless File.exists?('opal.js') and File.exist?('opal-parser.js')
  abort 'opal.js and opal-parser.js must exist. Run `rake build`.'
end

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
end
