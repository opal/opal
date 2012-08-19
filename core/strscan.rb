class StringScanner
  attr_reader :pos
  attr_reader :matched

  def initialize(string)
    @string  = string
    @pos     = 0
    @matched = ''
    @working = string
  end

  def scan(regex)
    %x{
      var regex  = new RegExp('^' + regex.toString().substring(1, regex.toString().length - 1)),
          result = regex.exec(#@working);

      if (result == null) {
        #@matched = '';

        return nil;
      }
      else if (typeof(result) === 'object') {
        #@pos      += result[0].length;
        #@working  = #@working.substring(result[0].length);
        #@matched  = result[0];

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

  def check(regex)
    %x{
      var regexp = new RegExp('^' + regex.toString().substring(1, regex.toString().length - 1)),
          result = regexp.exec(#@working);

      if (result == null) {
        return this.matched = nil;
      }

      return this.matched = result[0];
    }
  end

  def peek(length)
    `#@working.substring(0, length)`
  end

  def eos?
    `#@working.length === 0`
  end
end