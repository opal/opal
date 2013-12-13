source 'https://rubygems.org'
gemspec

# Stick with older racc until
# https://github.com/tenderlove/racc/issues/32
# and
# https://github.com/tenderlove/racc/issues/22
# are solved.
gem 'racc', '< 1.4.10' if RUBY_VERSION.to_f < 1.9 or RUBY_ENGINE == 'jruby'
gem 'rubysl', :platform => :rbx

group :repl do
  gem 'therubyracer', :platform => :mri, :require => 'v8'
  gem 'therubyrhino', :platform => :jruby
end
