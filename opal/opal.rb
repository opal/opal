require 'corelib/runtime'
require 'corelib/helpers'
require 'corelib/module'
require 'corelib/class'
require 'corelib/basic_object'
require 'corelib/kernel'
require 'corelib/nil_class'
require 'corelib/boolean'
require 'corelib/error'
require 'corelib/regexp'
require 'corelib/comparable'
require 'corelib/enumerable'
require 'corelib/enumerator'
require 'corelib/array'
require 'corelib/hash'
require 'corelib/string'
require 'corelib/match_data'
require 'corelib/encoding'
require 'corelib/numeric'
require 'corelib/math'
require 'corelib/proc'
require 'corelib/method'
require 'corelib/range'
require 'corelib/time'
require 'corelib/struct'
require 'corelib/io'
require 'corelib/main'

# regexp matches
$& = $~ = $` = $' = nil

# stub library path
$: = []
$" = []

# split lines
$/ = "\n"
$, = nil

ARGV = []
ARGF = Object.new
ENV  = {}

$VERBOSE = false
$DEBUG   = false
$SAFE    = 0

RUBY_PLATFORM       = 'opal'
RUBY_ENGINE         = 'opal'
RUBY_VERSION        = '2.0.0'
RUBY_ENGINE_VERSION = '0.6.0'
RUBY_RELEASE_DATE   = '2013-11-20'
