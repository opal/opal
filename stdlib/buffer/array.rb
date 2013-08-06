class Buffer

class Array < Native
  def self.for(bits, type)
    $$["#{Buffer.name_for bits, type}Array"]
  end

  include Enumerable

  attr_reader :buffer, :type

  def initialize(buffer, bits, type)
    %x{
      var klass = #{Array.for(bits, type)};

      #{super(`new klass(#{buffer.to_native})`)}
    }

    @buffer = buffer
    @type   = type
  end

  def bits
    `#@native.BYTES_PER_ELEMENT * 8`
  end

  def [](index, offset = nil)
    offset ? `#@native.subarray(index, offset)` : `#@native[index]`
  end

  def []=(index, value)
    `#@native[index] = value`
  end

  def bytesize
    `#@native.byteLength`
  end

  def each
    return enum_for :each unless block_given?

    %x{
      for (var i = 0, length = #@native.length; i < length; i++) {
        #{yield `#@native[i]`}
      }
    }

    self
  end

  def length
    `#@native.length`
  end

  def merge! (other, offset = undefined)
    `#@native.set(#{other.to_native}, offset)`
  end

  alias size length
end

end
