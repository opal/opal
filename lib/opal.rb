require 'opal/parser'
require 'opal/builder'
require 'opal/context'

# Opal is a set of build tools and runtime utilies for compiling ruby
# source code into javascript. Opal can use therubyracer to provide a
# ruby context for evaluating the generated javascript against the
# provided runtime.
module Opal
  OPAL_DIR = File.expand_path('../..', __FILE__)
end

