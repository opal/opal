
Gem::Specification.new do |s|
  s.name         = "core"
  s.version      = "0.0.1"
  s.authors      = ["Adam Beynon"]
  s.email        = ["adam@adambeynon.com"]
  s.homepage     = "http://github.com/adambeynon/opal"
  s.summary      = "Core libraries for opal"

  s.files        = Dir.glob("{bin,lib}/**/*") + %w[README.md]
  s.require_path = "lib"

  s.test_files   = Dir.glob "spec/**/*.rb"
end

