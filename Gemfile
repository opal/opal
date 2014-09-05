source 'https://rubygems.org'
gemspec

# Stick with older racc until
# https://github.com/tenderlove/racc/issues/22
# is solved.
gem 'racc', '< 1.4.10' if RUBY_ENGINE == 'jruby'
gem 'json', '< 1.8.1'  if RUBY_VERSION.to_f == 2.1 and RUBY_ENGINE == 'ruby'
gem 'rubysl', :platform => :rbx
gem 'thin', platform: :mri

# Uncomment to try with sprockets 3.0:
#
#   gem 'sprockets', github: 'sstephenson/sprockets', branch: 'master'

group :repl do
  gem 'therubyracer', :platform => :mri, :require => 'v8'
  gem 'therubyrhino', :platform => :jruby
end

unless ENV['CI']
  gem 'rb-fsevent'
  gem 'guard', require: false
  gem 'terminal-notifier-guard'
end

gem 'mspec', github: 'opal/mspec'
