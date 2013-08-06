class Buffer

class View < Native
  def self.supported?
    `typeof(DataView) != "undefined"`
  end

  attr_reader :buffer, :offset

  def initialize(buffer, offset = nil, length = nil)
    if offset && length
      super(`new DataView(#{buffer.to_native}, #{offset.to_native}, #{length.to_native})`)
    elsif offset
      super(`new DataView(#{buffer.to_native}, #{offset.to_native})`)
    else
      super(`new DataView(#{buffer.to_native})`)
    end

    @buffer = buffer
    @offset = offset
  end

  def length
    `#@native.byteLength`
  end

  alias size length

  def get(offset, bits = 8, type = :unsigned, little = false)
    `#@native["get" + #{Buffer.name_for bits, type}](offset, little)`
  end

  alias [] get

  def set(offset, value, bits = 8, type = :unsigned, little = false)
    `#@native["set" + #{Buffer.name_for bits, type}](offset, value, little)`
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

end
