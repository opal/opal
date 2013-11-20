require 'core/runtime'
require 'core/helpers'
require 'core/module'
require 'core/class'
require 'core/basic_object'
require 'core/kernel'
require 'core/nil_class'
require 'core/boolean'
require 'core/error'
require 'core/regexp'
require 'core/comparable'
require 'core/enumerable'
require 'core/enumerator'
require 'core/array'
require 'core/hash'
require 'core/string'
require 'core/match_data'
require 'core/encoding'
require 'core/numeric'
require 'core/proc'
require 'core/method'
require 'core/range'
require 'core/time'
require 'core/struct'
require 'core/io'
require 'core/main'
require 'native'

# regexp matches
$& = $~ = $` = $' = nil

# stub library path
$: = []
$" = []

# split lines
$/ = "\n"
$, = " "

ARGV = []
ARGF = Object.new
ENV  = {}

$VERBOSE = false
$DEBUG   = false
$SAFE    = 0

RUBY_PLATFORM       = 'opal'
RUBY_ENGINE         = 'opal'
RUBY_VERSION        = '1.9.3'
RUBY_ENGINE_VERSION = '0.5.3'
RUBY_RELEASE_DATE   = '2013-11-20'
