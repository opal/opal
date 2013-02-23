require 'bundler'
Bundler.require

run Opal::Server.new { |s|
  s.main = 'opal/spec/sprockets_runner'
  s.append_path 'spec'
  s.debug = false
}
