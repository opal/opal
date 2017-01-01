source 'https://rubygems.org'
gemspec

tilt_version = ENV['TILT_VERSION']
rack_version = ENV['RACK_VERSION']
sprockets_version = ENV['SPROCKETS_VERSION']

# Stick with older racc until
# https://github.com/tenderlove/racc/issues/22
# is solved.
gem 'racc', '< 1.4.10', platform: :jruby
gem 'json', '< 1.8.1',  platform: :ruby if RUBY_VERSION.to_f == 2.1
gem 'rubysl', platform: :rbx

gem 'puma' # Some browsers have problems with WEBrick

gem 'rack', rack_version if rack_version
gem 'tilt', tilt_version if tilt_version
gem 'sprockets', sprockets_version if sprockets_version

group :repl do
  gem 'therubyracer', platform: :mri, require: false
  gem 'therubyrhino', platform: :jruby, require: false
end

unless ENV['CI']
  gem 'rb-fsevent'
  gem 'guard', require: false

  if RUBY_PLATFORM =~ /darwin/
    gem 'terminal-notifier-guard'
    gem 'terminal-notifier'
  end
end

gem 'mspec', path: 'spec/mspec'

gem 'selenium-webdriver', '>= 3.0.0.beta3.1'

gem 'redcarpet', group: :doc
