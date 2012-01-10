class Buffer
  def self.name_for(bits, type)
    "#{case type
      when :unsigned then 'Uint'
      when :signed   then 'Int'
      when :float    then 'Float'
    end}#{bits}"
  end

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
