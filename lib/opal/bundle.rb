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
      lib_files = Dir["{lib}/**/*.rb"].map do |lib|
        code = @builder.parse File.read(lib), options
        path = lib[4, lib.length - 7]
        "\"#{path}\": #{code}"
      end

      bundle = []
      bundle << %[opal.gem({\n]
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

