class Buffer
  def self.name_for(bits, type)
    "#{case type
      when :unsigned then 'Uint'
      when :signed   then 'Int'
      when :float    then 'Float'
    end}#{bits}"
  end

  class Array
    def self.for(bits, type)
      `#{Buffer.name_for bits, type}Array`
    end

    include Native
    include Enumerable

    attr_reader :buffer, :bits, :type

    def initialize(buffer, bits, type)
      super(`new #{Array.for(bits, type)}(#{buffer.to_native})`)

      @buffer = buffer
      @bits   = `#@native.BYTES_PER_ELEMENT * 8`
      @type   = type
    end

    def [](index, offset=nil)
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
    end

    def length
      `#@native.length`
    end

    def merge!(other, offset = undefined)
      `#@native.set(#{other.to_native}, offset)`
    end

    alias size length
  end

  class View
    include Native

    attr_reader :buffer, :offset, :length

    def initialize(buffer, offset = nil, length = nil)
      super(`new DataView(#{buffer.to_native}, #{offset.to_native}, #{length.to_native})`)

      @buffer = buffer
      @offset = offset
      @length = length
    end

    def get(offset, bits = 8, type = :unsigned, little = false)
      `#@native.get#{Buffer.name_for bits, type}(offset, little)`
    end

    alias [] get

    def set(offset, value, bits = 8, type = :unsigned, little = false)
      `#@native.set#{Buffer.name_for bits, type}(offset, value, little)`
    end

    alias []= set

    def get_int8(offset, little = false); `#@native.getInt8(offset, little)`; end
    def set_int8(offset, value, little = false); `#@native.setInt8(offset, value, little)`; end

    def get_uint8(offset, little = false); `#@native.getUint8(offset, little)`; end
    def set_uint8(offset, value, little = false); `#@native.setUint8(offset, value, little)`; end

    def get_int16(offset, little = false); `#@native.getInt16(offset, little)`; end
    def set_int16(offset, value, little = false); `#@native.setInt16(offset, value, little)`; end

    def get_uint16(offset, little = false); `#@native.getUint16(offset, little)`; end
    def set_uint16(offset, value, little = false); `#@native.setUint16(offset, value, little)`; end

    def get_int32(offset, little = false); `#@native.getInt32(offset, little)`; end
    def set_int32(offset, value, little = false); `#@native.setInt32(offset, value, little)`; end

    def get_uint32(offset, little = false); `#@native.getUint32(offset, little)`; end
    def set_uint32(offset, value, little = false); `#@native.setUint32(offset, value, little)`; end

    def get_float32(offset, little = false); `#@native.getFloat32(offset, little)`; end
    def set_float32(offset, value, little = false); `#@native.setFloat32(offset, value, little)`; end

    def get_float64(offset, little = false); `#@native.getFloat64(offset, little)`; end
    def set_float64(offset, value, little = false); `#@native.setFloat64(offset, value, little)`; end
  end

  include Native

  def initialize(size, bits = 1)
    super(`new ArrayBuffer(size * bits)`)
  end

  def length
    `#@native.byteLength`
  end

  alias size length

  def to_a(bits = 8, type = :unsigned)
    Array.new(self, bits, type)
  end

  def view(offset = nil, length = nil)
    View.new(self, offset, length)
  end
end
