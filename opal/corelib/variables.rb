# backtick_javascript: true
# use_strict: true

# regexp matches
%x{$gvars['&'] = $gvars['~'] = $gvars['`'] = $gvars["'"] = nil}

# requires
$LOADED_FEATURES = $" = `Opal.loaded_features`
$LOAD_PATH       = $: = []

# split lines
$/ = "\n"
$, = nil

::ARGV = `Opal.platform.argv`
::ARGV.shift if ::ARGV.first == '--'
::ARGF = ::Object.new

$VERBOSE = false
$DEBUG   = false
$SAFE    = 0
