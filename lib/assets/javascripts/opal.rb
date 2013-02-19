require 'opal/runtime'
require 'opal/class'
require 'opal/basic_object'
require 'opal/kernel'
require 'opal/nil_class'
require 'opal/boolean'
require 'opal/error'
require 'opal/regexp'
require 'opal/comparable'
require 'opal/enumerable'
require 'opal/array'
require 'opal/hash'
require 'opal/string'
require 'opal/numeric'
require 'opal/proc'
require 'opal/range'
require 'opal/time'
require 'opal/json'

# regexp matches
$~ = nil

# split lines
$/ = "\n"

RUBY_ENGINE   = 'opal'
RUBY_PLATFORM = 'opal'

def to_s
  'main'
end

def include(mod)
  Object.include mod
end
