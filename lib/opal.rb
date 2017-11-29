# frozen_string_literal: true
require 'opal/config'
require 'opal/compiler'
require 'opal/builder'
require 'opal/builder_processors'
require 'opal/erb'
require 'opal/paths'
require 'opal/version'
require 'opal/errors'
require 'opal/source_map'
require 'opal/deprecations'

# Opal is a ruby to javascript compiler, with a runtime for running
# in any JavaScript environment.
module Opal
  autoload :Server, 'opal/server'
  autoload :SimpleServer, 'opal/simple_server'
end
