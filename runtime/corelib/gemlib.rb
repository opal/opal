# ...........................................................
# GEMLIB - only loaded when running inside v8 in gem
#

# In gem, use 'opal-ruby-. Browser (default) uses 'opal-browser'
RUBY_ENGINE = 'opal-ruby'

# Update load paths (aliasing does not yet work as planned)
$: = $LOAD_PATH = `opal_filesystem.find_paths`

module Kernel
  def require(path)
    %x{
      var resolved = opal_filesystem.require(#{path}, #{$:});

      if (resolved === false) {
        return false;
      }
      else if (!resolved) {
        #{ raise LoadError, "cannot load file -- #{path}" };
      }
      else {
        return true;
      }
    }
  end
end
