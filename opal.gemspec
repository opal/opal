version = YAML.load(File.read('package.yml'))['version']

Gem::Specification.new do |s|
  s.name         = "opal"
  s.version      = version
  s.authors      = ["Adam Beynon"]
  s.email        = ["adam@adambeynon.com"]
  s.homepage     = "http://opalscript.org"
  s.summary      = "Ruby runtime and core library for javascript"
  s.description  = "Ruby runtime and core library for javascript"

  s.files        = Dir["{bin,lib,runtime,corelib,stdlib}/**/*"] + %w[README.md]
  s.require_path = "lib"
  s.executables  = ['opal']

  s.add_runtime_dependency "rbp", "~> 0.0.1"
end

