require 'opal/build_methods'

module Opal

  class Bundle
    include BuildMethods

    attr_reader :gem

    def initialize(gem)
      @gem = gem
    end

    def wrap_source(full_path, relative_path = nil)
      relative_path ||= full_path
      content = compile_source full_path
      "'#{relative_path}': #{content}\n"
    end

    # Actually build the bundle. Returns the result, for now, as a string.
    #
    # @return {String} bundled packages
    def build(options = {})
      gem = @gem
      files = gem.lib_files
      # files += @gem.test_files if @options[:test_files]

      bundle = []
      bundle << %[opal.register("#{gem.name}", {]
      bundle << %[  "name": #{gem.name.inspect},]
      bundle << %[  "version": #{gem.version.inspect},]
      bundle << %[  "require_paths": #{gem.require_paths.inspect},]
      bundle << %[  "files": {]
      bundle << %[    #{files.map { |f| wrap_source f }.join(",\n    ")}]
      bundle << %[  }]
      bundle << %[});]

      result = bundle.join ''
      out = options[:out] || "#{gem.name}-#{gem.version}.js"
      FileUtils.mkdir_p File.dirname(out)

      File.open(out, 'w+') { |o| o.write result }
    end
  end
end

