require 'fileutils'

module Opal
  # A Bundle is a gem or directory with code in it.
  class Bundle
    # Returns true/false if the given config name is valid and
    # present
    def config? name
      @configs.key? name
    end

    def lib_files
      libs = files_to_build.select { |f| /^lib\// =~ f }
      libs
    end

    ##
    # Returns an array of "other files" to include. These will be
    # everything not inside "lib"

    def other_files
      other = files_to_build.reject { |f| /^lib\// =~ f }
      other
    end

    ##
    # Returns the files to build. This will look at the config :files
    # property first, and if files have not been manually set, then
    # just returns a default (which will be all ruby files in 'lib/'.

    def files_to_build
      self.files || Dir.chdir(@root) { Dir['lib/**/*.rb'] }
    end
  end
end

