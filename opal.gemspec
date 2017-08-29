lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'opal/version'

Gem::Specification.new do |spec|
  spec.name         = 'opal'
  spec.version      = Opal::VERSION
  spec.author       = ['Elia Schito', 'meh.', 'Adam Beynon']
  spec.email        = ['elia@schito.me', 'meh@schizofreni.co']

  spec.summary      = %{Ruby runtime and core library for JavaScript}
  spec.description  = %{Opal is a Ruby to JavaScript compiler. It is source-to-source, making it fast as a runtime. Opal includes a compiler (which can be run in any browser), a corelib and runtime implementation. The corelib/runtime is also very small.}
  spec.homepage     = 'https://opalrb.com'
  spec.license      = 'MIT'

  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.0.0'

  spec.add_dependency 'sourcemap', '~> 0.1.0'
  spec.add_dependency 'hike', '~> 1.2'
  spec.add_dependency 'ast', '>= 2.3.0'
  spec.add_dependency 'parser', '= 2.3.3.1'

  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'racc'
  spec.add_development_dependency 'rspec', '~> 3.6.0'
  spec.add_development_dependency 'octokit', '~> 2.4.0'
  spec.add_development_dependency 'bundler', '~> 1.5'
  spec.add_development_dependency 'yard', '~> 0.8.7'
  spec.add_development_dependency 'rack-test'
  spec.add_development_dependency 'opal-minitest'
  spec.add_development_dependency 'selenium-webdriver'
  spec.add_development_dependency 'benchmark-ips'
end
