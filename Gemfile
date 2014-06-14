source 'https://rubygems.org'
gemspec

# Stick with older racc until
# https://github.com/tenderlove/racc/issues/22
# is solved.
gem 'racc', '< 1.4.10' if RUBY_ENGINE == 'jruby'
gem 'json', '< 1.8.1'  if RUBY_VERSION.to_f == 2.1 and RUBY_ENGINE == 'ruby'
gem 'rubysl', :platform => :rbx

group :repl do
  gem 'therubyracer', :platform => :mri, :require => 'v8'
  gem 'therubyrhino', :platform => :jruby
end

unless ENV['CI']
  gem 'guard', require: false
  gem 'rb-fsevent', require: false
  gem 'terminal-notifier-guard'
end
