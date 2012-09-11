source :rubygems

gemspec

gem "rake"

# for rebuilding grammar.rb from grammar.y
group :grammar do
  gem "racc"
end

# running tests on command line
group :testing do
  gem "therubyracer", :require => 'v8'
  gem 'opal-spec'
end

group :docs do
  gem "redcarpet"
  gem "albino"
  gem "rack"
end