source 'https://rubygems.org'
gemspec

v = -> version { Gem::Version.new(version) if version }

ruby_version      = v[RUBY_VERSION]

tilt_version      = ENV['TILT_VERSION']
rack_version      = ENV['RACK_VERSION']
sprockets_version = ENV['SPROCKETS_VERSION']

gem 'json', '< 1.8.1',  platform: :ruby if ruby_version < v['2.2']
gem 'rack-test', '< 0.8' if ruby_version <= v['2.0']
gem 'coveralls', platform: :mri

# Some browsers have problems with WEBrick
gem 'puma' unless RUBY_ENGINE == 'truffleruby'

gem 'rack', rack_version if rack_version
gem 'tilt', tilt_version if tilt_version
gem 'sprockets', sprockets_version if sprockets_version

group :repl do
  if RUBY_VERSION.to_f >= 2.3
    gem 'mini_racer', platform: :mri, require: false
  else
    gem 'mini_racer', '< 0.2.0', platform: :mri, require: false
    gem 'libv8', '~> 6.3.0', platform: :mri, require: false
  end

  gem 'therubyrhino', platform: :jruby, require: false
end

group :browser do
  gem 'puppeteer-ruby', require: false
end

group :development do
  gem 'rb-fsevent'
  gem 'guard', require: false

  if RUBY_PLATFORM =~ /darwin/
    gem 'terminal-notifier-guard'
    gem 'terminal-notifier'
  end
end unless ENV['CI']

group :doc do
  gem 'redcarpet' unless RUBY_ENGINE == 'truffleruby'
end unless ENV['CI']
