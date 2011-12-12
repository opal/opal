module Kernel
  def require(path)
    `
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
    `
  end
end
