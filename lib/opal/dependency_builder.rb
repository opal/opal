#### Opal Dependency Builder
#
# The `DependencyBuilder` class is used to build all dependencies for
# an app/lib, including the opal runtime. Dependencies in opal are
# simply gems that have been installed or are referenced by any relevant
# `Gemfile` or `.gemspec`.
#
# To build a predefined set of dependencies, they can be passed directly
# to `DependencyBuilder`. Any gems here must be already installed and
# available to opal to find. An example may be:
#
#     Opal::DependencyBuilder.new(:gems => ['opal-spec']).build
#
# This will build the `opal-spec` dependency into the working directory.
# This will create `opal-spec.js` and `opal-spec.debug.js`, which are the
# release and debug versions of the gem respectively.
#
# The alternative to this approach is to use a `Gemfile`. Opal can pick
# out dependencies from a `Gemfile` in the current working directory. As
# there will be some non-opal dependnecies in the `Gemfile`, all gems that
# should be built **must** be inside an `:opal` group:
#
#     # Gemfile
#     gem "opal"
#     gem "therubyracer"
#
#     group :opal do
#       gem "opal-spec"
#     end
#
# Now running the dependency builder as:
#
#     Opal::DependencyBuilder.new.build
#
# Will built all dependnecies inside the opal group (just `opal-spec`) in
# both debug and release mode.
#
# When developing a gem for opal, the `.gemspec` already has a list of
# buildable gems inside the gem specification. If a `.gemspec` is also
# found then all runtime dependnecies will be built as well. It is crucial
# that **only** dependencies to run inside opal should be listed as a runtime
# dependency.
#
# Note, `opal` is **not** a runtime dependency, as it is built as a special
# case. Whenever `DependencyBuilder` is run, `opal.js` and `opal.debug.js`
# are also built.
#
# Finally, to write to a custom output directory, `:out` can be passed. This
# should be a directory and not a file as all dependnecies are built
# individually. For example:
#
#     Opal::DependencyBuilder.new(:gems => 'opal-spec', :out => 'build').build
#
# This will create `build/opal-spec.js` and `build/opal-spec.debug.js` (as well
# as the runtime files `opal.js` and `opal.debug.js`.
#

# The `Environment` is used to find relevant `Gemfile` and `.gemspec` to use to
# gather dependency names.
require 'opal/environment'

module Opal
  # `DependencyBuilder.new` takes an optional hash of build options which control
  # what dependencies are being built. The possible `options` are:
  #
  # * `:out`: specifies the directory to build the resulting files to. This
  #   directory will be created if it doesn't exist. _Defaults to `Dir.getwd`_.
  #
  # * `:gems`: an array (or single string) of gem dependencies to build. If not
  #   given then the `Gemfile` or `.gemspec` will be inspected as described above.
  class DependencyBuilder

    def initialize(options = {})
      @options      = options
    end

    def build
      @environment  = Environment.load Dir.getwd
      @verbose      = true
      @base         = File.expand_path(@options[:out] || '.')

      FileUtils.mkdir_p @base

      calculate_dependencies(@options[:gems]).each do |g|
        if spec = @environment.find_spec(g)
          build_spec spec
        else
          puts "Cannot find gem dependency #{g}"
        end
      end

      build_opal
    end

    # Gather a list of dependencies to build. These are taken from the
    # following order:
    #
    # 1. if rake task given a list, use those.
    # 2. Use dependnecies listed in Gemfile :opal group, if it exists
    # 3. Use all runtime dependnecies from local gemspec (if it exists)
    #
    # If none of these are applicable, no dependnecies will be built.
    #
    # @param [Array, String] gems gems passed to rake task
    # @return [Array<String>] an array of gem names to build
    def calculate_dependencies(gems)
      return Array(gems) if gems
      @environment.specs
    end

    def build_spec(spec)
      sources = spec.require_paths
      output  = File.expand_path("#{spec.name}.js", @options[:out] || '.')

      Dir.chdir(spec.full_gem_path) do
        Builder.new(:files => sources, :out => output).build
      end
    end

    # Builds/copies the opal runtime into the :out directory.
    def build_opal
      release = File.expand_path("opal.js", @options[:out] || '.')
      debug   = File.expand_path("opal.debug.js", @options[:out] || '.')
      puts "[opal] building runtime (#{release}, #{debug})"

      runtime  = Opal.runtime_code
      debugrun = Opal.runtime_debug_code

      File.open(release, 'w+') { |o| o.write runtime }
      File.open(debug, 'w+') { |o| o.write debugrun }
    end
  end
end
