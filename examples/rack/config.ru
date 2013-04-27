require 'bundler'
Bundler.require

# Use sprockets for handling our assets
map '/assets' do
  env = Sprockets::Environment.new

  # add all our opal load paths to sprockets
  Opal.paths.each { |p| env.append_path p }

  # add 'app' dir for serving app.rb
  env.append_path 'app'

  # run!
  run env
end

# Use simple Rack::Directory for serving current dir
run Rack::Directory.new('.')

