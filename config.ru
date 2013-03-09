require 'bundler'
Bundler.require

run Opal::Server.new { |s|
  Opal::Processor.arity_check_enabled = true

  s.debug = false

  s.append_path File.join(Gem::Specification.find_by_name('mspec').gem_dir, 'lib')
  s.append_path 'spec'
  s.main = 'ospec/main'
}

