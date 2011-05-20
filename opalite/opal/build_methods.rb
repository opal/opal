module Opal

  module BuildMethods

    # Returns the result of the compiled file ready for opal to load.
    #
    # `relative_path` is used for the name the built file should have.
    # This is used for building a singular rb or js file into the
    # compiled output, and will avoid the user's dir setup being exposed
    # in production code. It will be of the form
    # `lib/some_lib/some_lib.rb`
    #
    # @param [String] full_path The full pathname to the file to build
    # @paeam [String] relative_path The pathname to be used in the build
    # file.
    #
    # @return [String]
    def wrap_source(full_path, relative_path = nil)
      relative_path ||= full_path
      ext = File.extname full_path
      relative_path = relative_path.sub(/\.rb/, '.js') if ext == '.rb'
      content = compile_source full_path

      "opal.register('#{relative_path}', #{content});\n"
    end

    # Simply compile the given source code at the given path. This is
    # for compiling ruby or javascript sources only. This can be used
    # for any method that builds for the browser.
    #
    # @param [String] full_path location of the source to build
    # @return [String] compiled source
    def compile_source(full_path)
      ext = File.extname full_path
      src = File.read full_path

      case ext
      when '.js'
        "function($runtime, self, __FILE__) { #{src} }"

      when '.rb'
        src = Opal::RubyParser.new(src).parse!.generate_top
        "function($runtime, self, __FILE__) { #{src} }"

      else
        raise "Bad file type for wrapping. Must be ruby or javascript"
      end
    end
  end
end

