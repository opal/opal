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
require 'opal/date'
require 'opal/json'

# regexp matches
$~ = nil

$/ = "\n"

RUBY_ENGINE   = 'opal'
RUBY_PLATFORM = 'opal'
RUBY_VERSION  = '1.9.2'
OPAL_VERSION  = `__opal.version`

def to_s
  'main'
end

def include(mod)
  Object.include mod
end
