require 'opal/runtime'
require 'opal/module'
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
require 'opal/struct'
require 'opal/native'
require 'opal/io'

# regexp matches
$& = $~ = $` = $' = nil

# stub library path
$:            = []

# split lines
$/            = "\n"
$,            = " "

# native global
$$ = $global = Native(`Opal.global`)

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
RUBY_ENGINE_VERSION = '0.4.3'
RUBY_RELEASE_DATE = '2013-07-24'

def self.to_s
  'main'
end

def self.include(mod)
  Object.include mod
end
