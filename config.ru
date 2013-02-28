require 'bundler'
Bundler.require

run Opal::Server.new { |s|
  Opal::Processor.arity_check_enabled = true

  s.append_path 'spec'
  s.debug = false
  s.main = 'ospec/autorun'
}
