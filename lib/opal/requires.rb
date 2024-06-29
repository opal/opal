# frozen_string_literal: true

require 'opal/config'
require 'opal/compiler'
require 'opal/builder'
require 'opal/erb'
require 'opal/paths'
require 'opal/version'
require 'opal/errors'
require 'opal/source_map'
require 'opal/deprecations'

module Opal
  autoload :Server, 'opal/server' if RUBY_ENGINE != 'opal'
  autoload :SimpleServer, 'opal/simple_server'
end
