require 'opal/builder'

begin
  require 'rbp/package'
rescue LoadError
  abort "You need to install rbp. `gem install rbp`."
end

module Opal
  # Takes a package and builds it ready for the browser
  class Bundle
    # @return [Rbp::Package] the package this is bundling
    attr_reader :package

    attr_accessor :options

    def initialize(package)
      @package        = package
      @builder        = Builder.new
      @options = {}
    end

    # Simple build - returns a string which can be written to a file
    # FIXME: hardcoded lib directory to './lib'
    def build
      package_dir = @package.package_dir

      lib_files = @package.relative_lib_files.map do |lib|
        path = File.join package_dir, lib
        code = @builder.parse File.read(path), options

        "\"#{lib}\": #{code}"
      end

      bundle = []
      bundle << %[opal.package({\n]
      bundle << %[  name: "#{@package.name}",\n]
      bundle << %[  version: "#{@package.version}",\n]
      bundle << %[  libs: {\n]
      bundle << %[    #{lib_files.join ",\n    "}\n]
      bundle << %[  }\n]
      bundle << %[});\n]

      bundle.join ''
    end
  end
end

