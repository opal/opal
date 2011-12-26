class StringScanner
  def initialize(string)
    @string  = string
    @at      = 0
    @matched = ''
    @working = string
  end

  def scan(regex)
    %x{
      var regex  = new RegExp('^' + regex.toString().substring(1, regex.toString().length - 2)),
          result = regex.exec(#@working);

      if (result == null) {
        #@matched = '';

        return false;
      }
      else if (typeof(result) === 'object') {
        #@at      += result[0].length;
        #@working  = #@working.substring(result[0].length);
        #@matched  = result[0];

        return result[0];
      }
      else if (typeof(result) === 'string') {
        #@at      += result.length;
        #@working  = #@working.substring(result.length);

        return result;
      }
      else {
        return false;
      }
    }
  end

  def check(regex)
    `!!new RegExp('^' + regex.toString().substring(1, regex.toString().length - 2)).exec(#@working)`
  end

  def peek(length)
    `#@working.substring(0, length)`
  end

  def eos?
    `#@working.length === 0`
  end

  def matched
    @matched
  end
end
