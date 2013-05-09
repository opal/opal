require 'bundler'
Bundler.require

run Opal::Server.new { |s|
  s.append_path 'app'
  s.debug = true
  s.main = 'app'
}
