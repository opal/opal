# regexp matches
$& = $~ = $` = $' = nil

# requires
$LOADED_FEATURES = $" = `Opal.loaded_features`
$LOAD_PATHS      = $: = []

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
RUBY_VERSION        = '2.1.1'
RUBY_ENGINE_VERSION = '0.6.1'
RUBY_RELEASE_DATE   = '2014-04-15'
