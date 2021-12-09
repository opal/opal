require 'native'
require 'buffer/array'
require 'buffer/view'

class Buffer
  include Native::Wrapper

  def self.supported?
    !$$[:ArrayBuffer].nil?
  end

  def self.name_for(bits, type)
    part = case type
           when :unsigned then 'Uint'
           when :signed   then 'Int'
           when :float    then 'Float'
           end
    "#{part}#{bits}"
  end

  def initialize(size, bits = 8)
    if native?(size)
      super(size)
    else
      super(`new ArrayBuffer(size * (bits / 8))`)
    end
  end

  def length
    `#{@native}.byteLength`
  end

  def to_a(bits = 8, type = :unsigned)
    Array.new(self, bits, type)
  end

  def view(offset = nil, length = nil)
    View.new(self, offset, length)
  end

  def to_s
    to_a.to_a.pack('c*')
  end

  alias size length
end
