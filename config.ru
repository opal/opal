require 'bundler'
Bundler.require

require 'opal-sprockets'

run Opal::Server.new { |s|
  Opal::Processor.arity_check_enabled = true

  s.append_path 'spec'
  s.append_path File.join(Gem::Specification.find_by_name('mspec').gem_dir, 'lib')

  s.debug = false
  s.main = 'ospec/main'
}
