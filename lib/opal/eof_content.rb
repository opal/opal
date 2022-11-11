# frozen_string_literal: true

module Opal
  class EofContent
    DATA_SEPARATOR = "__END__\n"

    def initialize(tokens, source)
      @tokens = tokens
      @source = source
    end

    def eof
      return nil if @tokens.empty?

      eof_content = @source[last_token_position..-1]
      return nil unless eof_content

      # On Windows token position is off a bit, because Parser does not seem to compensate for \r\n
      # The first eof_content line on Windows may be for example "end\r\n"
      # Must match for it and \r\n and \n
      eof_content = eof_content.lines.drop_while { |line| /\A.*\r?\n?\z/.match?(line) && !line.start_with?('__END__') }

      if /\A__END__\r?\n?\z/.match?(eof_content[0])
        eof_content = eof_content[1..-1] || []
        eof_content.join
      elsif eof_content == ['__END__']
        ''
      end
    end

    private

    def last_token_position
      _, last_token_info = @tokens.last
      _, last_token_range = last_token_info
      last_token_range.end_pos
    end
  end
end
