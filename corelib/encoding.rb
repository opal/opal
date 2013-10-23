class Encoding
  def self.register(name, options = {}, &block)
    names    = [name] + (options[:aliases] || [])
    encoding = Class.new(self, &block).
      new(name, names, options[:ascii] || false, options[:dummy] || false)

    names.each {|name|
      const_set name.sub('-', '_'), encoding
    }
  end

  def self.find(name)
    return name if self === name

    constants.each {|const|
      encoding = const_get(const)

      if encoding.name == name || encoding.names.include?(name)
        return encoding
      end
    }

    raise ArgumentError, "unknown encoding name - #{name}"
  end

  attr_reader :name, :names

  def initialize(name, names, ascii, dummy)
    @name  = name
    @names = names
    @ascii = ascii
    @dummy = dummy
  end

  def ascii_compatible?
    @ascii
  end

  def dummy?
    @dummy
  end

  def to_s
    @name
  end

  def inspect
    "#<Encoding:#{@name}#{" (dummy)" if @dummy}>"
  end

  # methods to implement per encoding
  def each_byte(*)
    raise NotImplementedError
  end

  def getbyte(*)
    raise NotImplementedError
  end

  def bytesize(*)
    raise NotImplementedError
  end
end

Encoding.register "UTF-8", aliases: ["CP65001"], ascii: true do
  def each_byte(string, &block)
    %x{
      for (var i = 0, length = string.length; i < length; i++) {
        var code = string.charCodeAt(i);

        if (code <= 0x7f) {
          #{yield `code`};
        }
        else {
          var encoded = encodeURIComponent(string.charAt(i)).substr(1).split('%');

          for (var j = 0, encoded_length = encoded.length; j < encoded_length; j++) {
            #{yield `parseInt(encoded[j], 16)`};
          }
        }
      }
    }
  end

  def bytesize
    bytes.length
  end
end

Encoding.register "UTF-16LE" do
  def each_byte(string, &block)
    %x{
      for (var i = 0, length = string.length; i < length; i++) {
        var code = string.charCodeAt(i);

        #{yield `code & 0xff`};
        #{yield `code >> 8`};
      }
    }
  end

  def bytesize
    bytes.length
  end
end

Encoding.register "ASCII-8BIT", aliases: ["BINARY"], ascii: true do
  def each_byte(string, &block)
    %x{
      for (var i = 0, length = string.length; i < length; i++) {
        #{yield `string.charCodeAt(i) & 0xff`};
      }
    }
  end

  def bytesize
    bytes.length
  end
end

class String
  `def.encoding = #{Encoding::UTF_16LE}`
end
