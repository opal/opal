require 'bundler'
Bundler.require

run Opal::Server.new { |s|
  s.main = 'application'
  s.append_path 'app'

  # use a cache, for example purposes
  # s.sprockets.cache = Opal::Sprockets::MemoryStore.new
  # s.sprockets.cache = ::Sprockets::Cache::FileStore.new('tmp/cache')
}
