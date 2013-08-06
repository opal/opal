require 'buffer/array'
require 'buffer/view'

class Buffer < Native
  def self.supported?
    `typeof(ArrayBuffer) != "undefined"`
  end

  def self.name_for(bits, type)
    "#{case type
      when :unsigned then 'Uint'
      when :signed   then 'Int'
      when :float    then 'Float'
    end}#{bits}"
  end

  def initialize(size, bits = 8)
    if Native === size
      super(size)
    else
      super(`new ArrayBuffer(size * (bits / 8))`)
    end
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
