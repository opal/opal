require 'bundler'
Bundler.require

run Opal::Server.new { |s|
  s.main = 'application'
  s.append_path 'app'

  s.sprockets.cache = Sprockets::Cache::FileStore.new("tmp/cache/assets")
}
