require 'capybara/rspec'

if RUBY_VERSION.to_f > 1.8 and not(ENV['CI'])
  require 'capybara-webkit'
  Capybara.javascript_driver = :webkit
end
