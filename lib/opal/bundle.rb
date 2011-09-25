require 'opal/builder'

module Opal
  class Bundle
    attr_accessor :name
    attr_accessor :version
    attr_accessor :options

    def initialize
      @builder = Builder.new
      @options = {}
    end

    def build
      lib_files = Dir["**/*.rb"].map do |lib|
        code = @builder.parse File.read(lib), options

        "\"#{lib}\": #{code}"
      end

      bundle = []
      bundle << %[opal.package({\n]
      bundle << %[  name: "#{@name}",\n]
      bundle << %[  version: "#{@version}",\n]
      bundle << %[  libs: {\n]
      bundle << %[    #{lib_files.join ",\n    "}\n]
      bundle << %[  }\n]
      bundle << %[});\n]

      bundle.join ''
    end
  end
end

