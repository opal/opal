version = File.read('VERSION').strip

Gem::Specification.new do |s|
  s.name         = "opal"
  s.version      = version
  s.authors      = ["Adam Beynon"]
  s.email        = ["adam@adambeynon.com"]
  s.homepage     = "http://opalscript.org"
  s.summary      = "Ruby runtime and core library for javascript"

  s.files        = Dir["{bin,lib,opal_lib,runtime}/**/*"] + %w[README.md]
  s.require_path = "opal_lib"
  s.executables  = ['opal']
end

