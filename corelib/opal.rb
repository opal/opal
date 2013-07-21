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
require 'opal/enumerator'
require 'opal/array'
require 'opal/hash'
require 'opal/string'
require 'opal/numeric'
require 'opal/proc'
require 'opal/range'
require 'opal/time'
require 'opal/json'
require 'opal/native'

# regexp matches
$& = $~ = $` = $' = nil

# stub library path
$:            = []

# split lines
$/            = "\n"

# native global
$$ = $global = `Opal.global`

ARGV          = []
ARGF          = Object.new
ENV           = {}
TRUE          = true
FALSE         = false
NIL           = nil

STDERR        = $stderr = Object.new
STDIN         = $stdin  = Object.new
STDOUT        = $stdout = Object.new

RUBY_PLATFORM = 'opal'
RUBY_ENGINE   = 'opal'
RUBY_VERSION  = '1.9.3'
RUBY_RELEASE_DATE = '2013-05-02'

def self.to_s
  'main'
end

def self.include(mod)
  Object.include mod
end
