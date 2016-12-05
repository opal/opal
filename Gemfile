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

# thin requires rack < 2
gem 'thin', platform: :mri if !rack_version || (rack_version < '2')

gem 'rack', rack_version if rack_version
gem 'tilt', tilt_version if tilt_version
gem 'sprockets', sprockets_version if sprockets_version

group :repl do
  gem 'therubyracer', platform: :mri, require: 'v8'
  gem 'therubyrhino', platform: :jruby
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

gem 'redcarpet', group: :doc
