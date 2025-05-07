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
$. = 0
$0 = `Opal.platform.argv[0]`
$$ = `Opal.platform.process_pid()`
$? = nil
$* = ::ARGV = `Opal.platform.argv.slice(1)`

$VERBOSE = false
$DEBUG   = false
$SAFE    = 0
