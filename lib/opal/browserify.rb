module Opal

  # Takes a package and builds it ready for the browser
  class Browserify

    def initialize(package)
      @package = package
      @builder = Builder.new
    end

    # Simple build - returns a string which can be written to a file
    # FIXME: hardcoded lib directory to './lib'
    def build
      libs = @package.lib_files
      libs.map! do |f|
        path = File.join @package.root, './lib', f
        src = @builder.compile_source path
        "\"#{f}\": #{src}"
      end

      bundle = []
      bundle << %[opal.package({\n]
      bundle << %[  name: "#{@package.name}",\n]
      bundle << %[  version: "#{@package.version}",\n]
      bundle << %[  libs: {\n]
      bundle << %[    #{libs.join ",\n    "}\n]
      bundle << %[  }\n]
      bundle << %[});\n]

      bundle.join ''
    end
  end
end

