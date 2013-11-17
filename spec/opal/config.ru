require 'bundler'
Bundler.require
require 'opal-sprockets'

Dir.chdir File.expand_path('../../', __FILE__) # go to opal gem root
ENV['OPAL_SPEC'] = [File.dirname(__FILE__)].join(',')

run Opal::Server.new { |s|
  Opal::Processor.arity_check_enabled = true

  s.append_path 'spec'
  s.append_path File.join(Gem::Specification.find_by_name('mspec').gem_dir, 'lib')

  s.debug = false
  s.main = 'mspec/main'
  s.index_path = 'spec/index.html'
}
