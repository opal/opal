require 'bundler'
Bundler.require

run Opal::Server.new { |s|
  Opal::Processor.arity_check_enabled = true

  s.debug = false

  # mspec
  s.append_path 'mspec'
  s.main = 'ospec/main'

  # opal-spec
  # s.main = 'opal/spec/sprockets_runner'

  s.append_path 'spec'
}
