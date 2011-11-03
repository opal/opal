require 'ruby_parser'

require 'opal/parser/processor'
require 'opal/parser/scope'

module Opal
  class Parser
    def parse(source, options = {})
      @options = options
      @file    = "__OPAL_LIB_FILE_STRING"

      begin
        parser = RubyParser.new
      rescue => e
        raise e.message + " (on line #{parser.lexer.lineno})\n#{parser.lexer.src.peek 100}"
      end

      reset
      code = top parser.parse(source, @file), options

      {
        :code     => code,
        :methods  => @id_tbl,
        :ivars    => @ivar_tbl
      }
    end

    ##
    # Builds the runtime ready to be used to boot the context (irb), or a
    # standalone file ready to be used in a browser.
    #
    # Returns a string ready to be javascript eval().

    def self.build_runtime
      dir   = File.join OPAL_DIR, 'build'
      code  = []

      code << File.read(File.join dir, 'opal.js')

      method_ids = YAML.load(File.read(File.join dir, 'methods.yml'))

      ids = method_ids.to_a.map do |m|
        "#{m[0].inspect}: #{m[1].inspect}"
      end

      code << "opal.method_ids({#{ids.join(', ')}});"
      code << "opal.init();"

      code.join
    end
  end
end
