class StringScanner
  attr_reader :pos
  attr_reader :matched

  def initialize(string)
    @string  = string
    @pos     = 0
    @matched = nil
    @working = string
    @match = []
  end

  attr_reader :string

  def bol?
    `#@pos === 0 || #@string.charAt(#@pos - 1) === "\n"`
  end

  def scan(regex)
    %x{
      var regex  = new RegExp('^' + regex.toString().substring(1, regex.toString().length - 1)),
          result = regex.exec(#@working);

      if (result == null) {
        return #{self}.matched = nil;
      }
      else if (typeof(result) === 'object') {
        #@prev_pos = #@pos;
        #@pos     += result[0].length;
        #@working  = #@working.substring(result[0].length);
        #@matched  = result[0];
        #@match    = result;

        return result[0];
      }
      else if (typeof(result) === 'string') {
        #@pos     += result.length;
        #@working  = #@working.substring(result.length);

        return result;
      }
      else {
        return nil;
      }
    }
  end

  def [](idx)
    %x{
      var match = #@match;

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

  def check(regex)
    %x{
      var regexp = new RegExp('^' + regex.toString().substring(1, regex.toString().length - 1)),
          result = regexp.exec(#@working);

      if (result == null) {
        return #{self}.matched = nil;
      }

      return #{self}.matched = result[0];
    }
  end

  def peek(length)
    `#@working.substring(0, length)`
  end

  def eos?
    `#@working.length === 0`
  end

  def skip(re)
    %x{
      re = new RegExp('^' + re.source)
      var result = re.exec(#@working);

      if (result == null) {
        return #{self}.matched = nil;
      }
      else {
        var match_str = result[0];
        var match_len = match_str.length;
        #{self}.matched = match_str;
        self.prev_pos = self.pos;
        #{self}.pos += match_len;
        #{self}.working = #{self}.working.substring(match_len);
        return match_len;
      }
    }
  end

  def get_byte()
    %x{
      var result = nil;
      if (#{self}.pos < #{self}.string.length) {
        self.prev_pos = self.pos;
        #{self}.pos += 1;
        result = #{self}.matched = #{self}.working.substring(0, 1);
        #{self}.working = #{self}.working.substring(1);
      }
      else {
        #{self}.matched = nil;
      }

      return result;
    }
  end

  # not exactly, but for now...
  alias getch get_byte

  def pos=(pos)
    %x{
      if (pos < 0) {
        pos += #{@string.length};
      }
    }

    @pos = pos
    @working = `#{@string}.slice(pos)`
  end

  def rest
    @working
  end

  def terminate
    @match = nil
    self.pos = @string.length
  end

  def unscan
    @pos = @prev_pos
    @prev_pos = nil
    @match = nil
    self
  end
end
