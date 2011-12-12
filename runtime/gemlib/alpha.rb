# In gem, use 'opal-ruby'. Browser uses 'opal-browser'.
RUBY_ENGINE = 'opal-ruby'

# Gvars do not currently support aliasing - so we need to change both.
$: = $LOAD_PATH = `opal_filesystem.find_paths`
