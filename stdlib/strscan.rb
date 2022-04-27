class StringScanner
  attr_reader :pos, :matched

  def initialize(string)
    @string  = string
    @pos     = 0
    @matched = nil
    @working = string
    @match   = []
  end

  attr_reader :string

  def beginning_of_line?
    `#{@pos} === 0 || #{@string}.charAt(#{@pos} - 1) === "\n"`
  end

  def scan(pattern)
    pattern = anchor(pattern)

    %x{
      var result = pattern.exec(#{@working});

      if (result == null) {
        return #{@matched} = nil;
      }
      #{@prev_pos} = #{@pos};
      #{@pos}     += result[0].length;
      #{@working}  = #{@working}.substring(result[0].length);
      #{@matched}  = result[0];
      #{@match}    = result;

      return result[0];
    }
  end

  def scan_until(pattern)
    pattern = anchor(pattern)

    %x{
      var working = #{@working}

      for(var i = 0; working.length != i; ++i) {
        var result  = pattern.exec(working.substr(i));
        if (result !== null) {
          var matched_size = i + result[0].length
          var matched = working.substr(0, matched_size)

          #{@matched}  = result[0]
          #{@match}  = result
          #{@prev_pos} = #{@pos} + i; // Position of first character of matched
          #{@pos} += matched_size // Position one after last character of matched
          #{@working} = working.substr(matched_size)

          return matched
        }
      }
      return #{@matched} = nil;
    }
  end

  def [](idx)
    if @match.empty?
      return nil
    end
    case idx
    when Symbol
      idx = idx.to_s
    when String
      # noop
    else
      idx = ::Opal.coerce_to!(idx, Integer, :to_int)
    end
    %x{
      var match = #{@match};

      if (idx < 0) {
        idx += match.length;
      }

      if (idx < 0 || idx >= match.length) {
        return nil;
      }

      if (match[idx] == null) {
        return nil;
      }

      return match[idx];
    }
  end

  def check(pattern)
    pattern = anchor(pattern)

    %x{
      var result = pattern.exec(#{@working});

      if (result == null) {
        return #{@matched} = nil;
      }

      return #{@matched} = result[0];
    }
  end

  def check_until(pattern)
    %x{
      var old_prev_pos = #{@prev_pos};
      var old_pos      = #{@pos};
      var old_working  = #{@working};

      var result = #{scan_until(pattern)};

      #{@prev_pos} = old_prev_pos;
      #{@pos}      = old_pos;
      #{@working}  = old_working;

      return result;
    }
  end

  def peek(length)
    `#{@working}.substring(0, length)`
  end

  def eos?
    `#{@working}.length === 0`
  end

  def exist?(pattern)
    %x{
      var result = pattern.exec(#{@working});

      if (result == null) {
        return nil;
      }
      else if (result.index == 0) {
        return 0;
      }
      else {
        return result.index + 1;
      }
    }
  end

  def skip(pattern)
    pattern = anchor(pattern)

    %x{
      var result = pattern.exec(#{@working});

      if (result == null) {
        #{@match} = [];
        return #{@matched} = nil;
      }
      else {
        var match_str = result[0];
        var match_len = match_str.length;

        #{@matched}   = match_str;
        #{@match}     = result;
        #{@prev_pos}  = #{@pos};
        #{@pos}      += match_len;
        #{@working}   = #{@working}.substring(match_len);

        return match_len;
      }
    }
  end

  def skip_until(pattern)
    %x{
      var result = #{scan_until(pattern)};

      if (result === nil) {
        return nil;
      }
      else {
        #{@matched} = result.substr(-1);

        return result.length;
      }
    }
  end

  def get_byte
    %x{
      var result = nil;

      if (#{@pos} < #{@string}.length) {
        #{@prev_pos}  = #{@pos};
        #{@pos}      += 1;
        result      = #{@matched} = #{@working}.substring(0, 1);
        #{@working}   = #{@working}.substring(1);
      }
      else {
        #{@matched} = nil;
      }

      return result;
    }
  end

  def match?(pattern)
    pattern = anchor(pattern)

    %x{
      var result = pattern.exec(#{@working});

      if (result == null) {
        return nil;
      }
      else {
        #{@prev_pos} = #{@pos};

        return result[0].length;
      }
    }
  end

  def pos=(pos)
    %x{
      if (pos < 0) {
        pos += #{@string.length};
      }
    }

    @pos     = pos
    @working = `#{@string}.slice(pos)`
  end

  def matched_size
    %x{
      if (#{@matched} === nil) {
        return nil;
      }

      return #{@matched}.length
    }
  end

  def post_match
    %x{
      if (#{@matched} === nil) {
        return nil;
      }

      return #{@string}.substr(#{@pos});
    }
  end

  def pre_match
    %x{
      if (#{@matched} === nil) {
        return nil;
      }

      return #{@string}.substr(0, #{@prev_pos});
    }
  end

  def reset
    @working = @string
    @matched = nil
    @pos     = 0
  end

  def rest
    @working
  end

  def rest?
    `#{@working}.length !== 0`
  end

  def rest_size
    rest.size
  end

  def terminate
    @match = nil
    self.pos = @string.length
  end

  def unscan
    @pos      = @prev_pos
    @prev_pos = nil
    @match    = nil

    self
  end

  alias bol? beginning_of_line?
  alias getch get_byte # not exactly the same, but for now...

  private

  def anchor(pattern)
    %x{
      var flags = pattern.toString().match(/\/([^\/]+)$/);
      flags = flags ? flags[1] : undefined;
      return new RegExp('^(?:' + pattern.source + ')', flags);
    }
  end
end
