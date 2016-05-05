# regexp matches
%x{$gvars['&'] = $gvars['~'] = $gvars['`'] = $gvars["'"] = nil}

# requires
$LOADED_FEATURES = $" = `Opal.loaded_features`
$LOAD_PATH       = $: = []

# split lines
$/ = "\n"
$, = nil

ARGV = []
ARGF = Object.new
ENV  = {}

$VERBOSE = false
$DEBUG   = false
$SAFE    = 0
