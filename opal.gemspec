
Gem::Specification.new do |s|
  s.name         = "opal"
  s.version      = "0.0.1"
  s.authors      = ["Adam Beynon"]
  s.email        = ["adam@adambeynon.com"]
  s.homepage     = "http://opalscript.org"
  s.summary      = "Ruby runtime and core library for javascript"

  s.files        = Dir["{bin,lib}/**/*"] + %w[README.md]
  s.require_path = "opal_lib"
end

