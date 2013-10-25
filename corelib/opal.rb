require 'runtime'
require 'module'
require 'class'
require 'basic_object'
require 'kernel'
require 'nil_class'
require 'boolean'
require 'error'
require 'regexp'
require 'comparable'
require 'enumerable'
require 'enumerator'
require 'array'
require 'hash'
require 'string'
require 'match_data'
require 'encoding'
require 'numeric'
require 'proc'
require 'range'
require 'time'
require 'struct'
require 'native'
require 'io'
require 'main'

# regexp matches
$& = $~ = $` = $' = nil

# stub library path
$:            = []

# split lines
$/            = "\n"
$,            = " "

ARGV          = []
ARGF          = Object.new
ENV           = {}

RUBY_PLATFORM = 'opal'
RUBY_ENGINE   = 'opal'
RUBY_VERSION  = '1.9.3'
RUBY_ENGINE_VERSION = '0.4.4'
RUBY_RELEASE_DATE = '2013-08-13'
