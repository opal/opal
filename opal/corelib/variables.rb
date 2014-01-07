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
