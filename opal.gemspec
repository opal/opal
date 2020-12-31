require_relative 'lib/opal/version'

Gem::Specification.new do |spec|
  spec.name         = 'opal'
  spec.version      = Opal::VERSION
  spec.author       = ['Elia Schito', 'meh.', 'Adam Beynon']
  spec.email        = ['elia@schito.me', 'meh@schizofreni.co']

  spec.summary      = %{Ruby runtime and core library for JavaScript}
  spec.description  = %{Opal is a Ruby to JavaScript compiler. It is source-to-source, making it fast as a runtime. Opal includes a compiler (which can be run in any browser), a corelib and runtime implementation. The corelib/runtime is also very small.}
  spec.homepage     = 'https://opalrb.com'
  spec.license      = 'MIT'

  spec.metadata["homepage_uri"]          = "https://opalrb.com/"
  spec.metadata["bug_tracker_uri"]       = "https://github.com/opal/opal/issues"
  spec.metadata["changelog_uri"]         = "https://github.com/opal/opal/blob/v#{spec.version}/CHANGELOG.md"
  spec.metadata["readme_uri"]            = "https://github.com/opal/opal/blob/v#{spec.version}/README.md"
  spec.metadata["api_documentation_uri"] = "http://opalrb.com/docs/api/v#{spec.version}/index.html"
  spec.metadata["guides_uri"]            = "http://opalrb.com/docs/guides/v#{spec.version}/index.html"
  spec.metadata["chat_uri"]              = "https://gitter.im/opal/opal"
  spec.metadata["source_code_uri"]       = "https://github.com/opal/opal"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  # Remove symlinks because Windows doesn't always support them.
  files = Dir.chdir(__dir__) { `git ls-files -z`.split("\x0") }.reject(&File.method(:symlink?))

  spec.files         = files.grep(%r{^(test|spec|features)/})
  spec.test_files    = files.grep_v(%r{^(test|spec|features)/})
  spec.executables   = files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.bindir        = 'exe'
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.3'

  spec.add_dependency 'ast', '>= 2.3.0'
  spec.add_dependency 'parser', '~> 3.0'

  spec.add_development_dependency 'sourcemap', '~> 0.1.0'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.9'
  spec.add_development_dependency 'octokit', '~> 4.9'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rack-test'
  spec.add_development_dependency 'selenium-webdriver'
  spec.add_development_dependency 'benchmark-ips'
  spec.add_development_dependency 'sinatra'
  spec.add_development_dependency 'rubocop', '~> 0.67.0'
  spec.add_development_dependency 'rubocop-performance', '~> 1.1.0'
end
