class Regexp
  `def.$$is_regexp = true`

  class << self
    def escape(string)
      %x{
        return string.replace(/([-[\]\/{}()*+?.^$\\| ])/g, '\\$1')
                     .replace(/[\n]/g, '\\n')
                     .replace(/[\r]/g, '\\r')
                     .replace(/[\f]/g, '\\f')
                     .replace(/[\t]/g, '\\t');
      }
    end

    def last_match(n=nil)
      if n.nil?
        $~
      else
        $~[n]
      end
    end

    alias quote escape

    def union(*parts)
      `new RegExp(parts.join(''))`
    end

    def new(regexp, options = undefined)
      `new RegExp(regexp, options)`
    end
  end

  def ==(other)
    `other.constructor == RegExp && self.toString() === other.toString()`
  end

  def ===(string)
    `#{match(string)} !== nil`
  end

  def =~(string)
    match(string) && $~.begin(0)
  end

  alias eql? ==

  def inspect
    `self.toString()`
  end

  def match(string, pos = undefined, &block)
    %x{
      if (pos === undefined) {
        pos = 0;
      } else {
        pos = #{Opal.coerce_to(pos, Integer, :to_int)};
      }

      if (string === nil) {
        return #{$~ = nil};
      }

      string = #{Opal.coerce_to(string, String, :to_str)};

      if (pos < 0) {
        pos += string.length;
        if (pos < 0) {
          return #{$~ = nil};
        }
      }

      var md, re = new RegExp(self.source, 'gm' + (self.ignoreCase ? 'i' : ''));

      while (true) {
        md = re.exec(string);
        if (md === null) {
          return #{$~ = nil};
        }
        if (md.index >= pos) {
          #{$~ = MatchData.new(`re`, `md`)}
          return block === nil ? #{$~} : #{block.call($~)};
        }
        re.lastIndex = md.index + 1;
      }
    }
  end

  def ~
    self =~ $_
  end

  def source
    `self.source`
  end

  alias to_s source
end
