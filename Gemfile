source :rubygems

gemspec

gem "rake"
gem "racc"

group :parser do
  gem 'opal-strscan', :git => 'git://github.com/adambeynon/opal-strscan.git'
  gem 'opal-racc', :git => 'git://github.com/adambeynon/opal-racc.git'
end

group :testing do
  gem "therubyracer", :require => 'v8'
  gem 'opal-spec', :git => 'git://github.com/adambeynon/opal-spec.git'
  gem "rspec"
end

group :docs do
  gem "redcarpet"
  gem "albino"
  gem "rack"
end