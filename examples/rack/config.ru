require 'bundler'
Bundler.require

run Opal::Server.new { |s|
  s.main = 'application'
  s.append_path 'app'
  s.index_path = 'index.html.erb'
}
