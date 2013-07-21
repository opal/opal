require 'opal/require_parser'
require 'erb'

module Opal
  class Builder

    BUILDERS = { ".rb" => :build_ruby, ".js" => :build_js, ".erb" => :build_erb }

    def self.build(name)
      Builder.new.build name
    end

    def initialize
      @paths = Opal.paths
    end

    def build(path)
      @segments = []
      @handled = {}

      require_asset path

      @segments.join
    end

    def require_asset(path)
      location = find_asset path

      build_asset location
    end

    def find_asset(path)
      file_types = %w[.rb .js .js.erb]

      @paths.each do |root|
        file_types.each do |type|
          test = File.join root, "#{path}#{type}"

          if File.exist? test
            return test
          end
        end
      end

      raise "Could not find asset: #{path}"
    end

    def build_asset(path)
      ext = File.extname path

      unless builder = BUILDERS[ext]
        raise "Unknown builder for #{ext}"
      end

      @segments << __send__(builder, path)
    end

    def build_ruby(path)
      parser = RequireParser.new
      result = parser.parse File.read(path)

      parser.requires.each do |r|
        require_asset r
      end

      result
    end

    def build_js(path)
      File.read(path)
    end

    def build_erb(path)
      ::ERB.new(File.read(path)).result binding
    end
  end
end
