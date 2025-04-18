# backtick_javascript: true

require 'corelib/string/encoding'

class ::IO
  class Buffer
    # for Opal internal use see "methods for Opal convenience" below

    # Types that can be requested from the buffer:
    #
    # :U8: unsigned integer, 1 byte
    # :S8: signed integer, 1 byte
    # :u16: unsigned integer, 2 bytes, little-endian
    # :U16: unsigned integer, 2 bytes, big-endian
    # :s16: signed integer, 2 bytes, little-endian
    # :S16: signed integer, 2 bytes, big-endian
    # :u32: unsigned integer, 4 bytes, little-endian
    # :U32: unsigned integer, 4 bytes, big-endian
    # :s32: signed integer, 4 bytes, little-endian
    # :S32: signed integer, 4 bytes, big-endian
    # :u64: unsigned integer, 8 bytes, little-endian
    # :U64: unsigned integer, 8 bytes, big-endian
    # :s64: signed integer, 8 bytes, little-endian
    # :S64: signed integer, 8 bytes, big-endian
    # :f32: float, 4 bytes, little-endian
    # :F32: float, 4 bytes, big-endian
    # :f64: double, 8 bytes, little-endian
    # :F64: double, 8 bytes, big-endian

    include Comparable

    class AccessError < ::StandardError; end
    class LockedError < ::StandardError; end

    DEFAULT_SIZE = 4096

    EXTERNAL = 1
    INTERNAL = 2
    MAPPED = 4
    SHARED = 8
    LOCKED = 32
    PRIVATE = 64
    READONLY = 128

    %x{
      let size_map = new Map()
      .set('U8', 1).set('S8', 1)
      .set('u16', 2).set('U16', 2).set('s16', 2).set('S16', 2)
      .set('u32', 4).set('U32', 4).set('s32', 4).set('S32', 4)
      .set('u64', 8).set('U64', 8).set('s64', 8).set('S64', 8)
      .set('f16', 2).set('F16', 2)
      .set('f32', 4).set('F32', 4)
      .set('f64', 8).set('F64', 8);

      let fun_map = new Map()
      .set('U8', 'Uint8').set('S8', 'Int8')
      .set('u16', 'Uint16').set('U16', 'Uint16').set('s16', 'Int16').set('S16', 'Int16')
      .set('u32', 'Uint32').set('U32', 'Uint32').set('s32', 'Int32').set('S32', 'Int32')
      .set('u64', 'BigUint64').set('U64', 'BigUint64').set('s64', 'BigInt64').set('S64', 'BigInt64')
      .set('f16', 'Float16').set('F16', 'Float16')
      .set('f32', 'Float32').set('F32', 'Float32')
      .set('f64', 'Float64').set('F64', 'Float64');

      function is_le(buffer_type_s) {
        let c = buffer_type_s[0];
        return (c === 'u' || c === 's' || c === 'f') ? true : false;
      }

      function op_not(source, target, length) {
        for(let i = 0; i < length;) {
          if ((length - i) > 4) {
            target.data_view.setUint32(i, ~source.data_view.getUint32(i));
            i += 4;
          } else {
            target.data_view.setUint8(i, ~source.data_view.getUint8(i));
            i++;
          }
        }
      }

      function op_and(source, target, length, mask) {
        let mask_length = mask.data_view.byteLength, m = 0;
        for(let i = 0; i < length; i++) {
          target.data_view.setUint8(i, source.data_view.getUint8(i) & mask.data_view.getUint8(m));
          m++;
          if (m >= mask_length) m = 0;
        }
      }

      function op_or(source, target, length, mask) {
        let mask_length = mask.data_view.byteLength, m = 0;
        for(let i = 0; i < length; i++) {
          target.data_view.setUint8(i, source.data_view.getUint8(i) | mask.data_view.getUint8(m));
          m++;
          if (m >= mask_length) m = 0;
        }
      }

      function op_xor(source, target, length, mask) {
        let mask_length = mask.data_view.byteLength, m = 0;
        for(let i = 0; i < length; i++) {
          target.data_view.setUint8(i, source.data_view.getUint8(i) ^ mask.data_view.getUint8(m));
          m++;
          if (m >= mask_length) m = 0;
        }
      }

      // fastest for buffers up to 256 bytes on FF
      function copy_dv_small(source_dv, target_dv, source_offset, offset, length) {
        for(let i = 0; i < length;) {
          if ((length - i) >= 4) {
            target_dv.setUint32(offset + i, source_dv.getUint32(source_offset + i));
            i += 4;
          } else {
            target_dv.setUint8(offset + i, source_dv.getUint8(source_offset + i));
            i++;
          }
        }
      }

      function copy_dv(source_dv, target_dv, source_offset, offset, length) {
        let source = new Uint8Array(source_dv.buffer, source_offset, length);
        (new Uint8Array(target_dv.buffer)).set(source, offset);
      }

      function endianess() {
        let uint32_a = new Uint32Array([0x11223344]);
        let uint8_a = new Uint8Array(uint32_a.buffer);
        if (uint8_a[0] === 0x44) return 4; // LITTLE_ENDIAN
        if (uint8_a[0] === 0x11) return 8; // BIG_ENDIAN
        return nil;
      }
    }

    LITTLE_ENDIAN = 4
    BIG_ENDIAN = 8
    NETWORK_ENDIAN = 8
    HOST_ENDIAN = `endianess()`

    class << self
      def for(string)
        # Ruby docs: Creates a zero-copy IO::Buffer from the given string’s memory.
        # Opal: We have to copy.
        raise(TypeError, 'arg must be a String') unless string.is_a?(String)
        buf = new(nil)
        `buf.data_view = new DataView((new Uint8Array(string.$bytes())).buffer)`
        `buf.readonly = true` if string.frozen?
        return yield buf if block_given?
        buf
      ensure
        `buf.readonly = true` if buf
      end

      def map(file, size = nil, offset = 0, flags = READONLY)
        # Create an IO::Buffer for reading from file by memory-mapping the file.
        # file should be a File instance, opened for reading.
        raise(NotImplementedError, 'IO::Buffer#map is not supported!')
      end

      def size_of(buffer_type)
        # Returns the size of the given buffer type(s) in bytes.
        size = 0
        if buffer_type.is_a?(Array)
          buffer_type.each do |type|
            size += `size_map.get(type.$to_s())`
          end
        else
          size = `size_map.get(buffer_type.$to_s())`
        end
        size
      end

      def string(length)
        # Creates a new string of the given length and yields a zero-copy IO::Buffer
        # instance to the block which uses the string as a source. The block is
        # expected to write to the buffer and the string will be returned.
        raise(ArgumentError, 'length must be a numer') unless length.is_a?(Number)
        raise(ArgumentError, 'length must be >= 0') if length < 0
        # We assume length is in bytes.
        buffer = new(length)
        yield buffer
        buffer.get_string
      end
    end

    def initialize(size = DEFAULT_SIZE, flags = 0)
      raise(NotImplementedError, 'mapped buffers are not supported') if (flags & MAPPED) > 0
      @readonly = (flags & READONLY) > 0
      @locked = (flags & LOCKED) > 0
      @external = (flags & EXTERNAL) > 0
      @internal = !@external
      # dont allocate internal data_view when size is nil
      # assuming it will be allocated and attached immediately
      # by surrounding code, e.g. by IO::Buffer.for()
      @data_view = `new DataView(new ArrayBuffer(size))` if size
    end

    #
    # special properties of the buffer
    #

    def external?
      # The buffer is external if it references the memory which is not allocated or mapped by the buffer itself.
      # A buffer created using ::for has an external reference to the string’s memory.
      # External buffer can’t be resized.
      @external
    end

    def internal?
      # If the buffer is internal, meaning it references memory allocated by the buffer itself.
      # An internal buffer is not associated with any external memory (e.g. string) or file mapping.
      # Internal buffers can be resized, and such an operation will typically invalidate all slices, but not always.
      @internal
    end

    def mapped?
      # If the buffer is mapped, meaning it references memory mapped by the buffer.
      # Mapped buffers can usually be resized, and such an operation will typically invalidate all slices, but not always.
      false
    end

    def private?
      # If the buffer is private, meaning modifications to the buffer will not be replicated to the underlying file mapping.
      true
    end

    def shared?
      # If the buffer is shared, meaning it references memory that can be shared with other processes
      # (and thus might change without being modified locally).
      false
    end

    #
    # logical operators
    #

    def ~
      # Generate a new buffer the same size as the source by applying the binary NOT
      # operation to the source.
      dup.not!
    end

    def not!
      # Modify the source buffer in place by applying the binary NOT operation to the source.
      raise(AccessError, 'Buffer has been freed!') if null?
      `op_not(self, self, self.data_view.byteLength)`
      self
    end

    def &(mask)
      # Generate a new buffer the same size as the source by applying the binary AND
      # operation to the source, using the mask, repeating as necessary.
      dup.and!(mask)
    end

    def and!(mask)
      # Modify the source buffer in place by applying the binary AND
      # operation to the source, using the mask, repeating as necessary.
      raise(AccessError, 'Buffer has been freed!') if null?
      `op_and(self, self, self.data_view.byteLength, mask)`
      self
    end

    def |(mask)
      # Generate a new buffer the same size as the source by applying the binary OR
      # operation to the source, using the mask, repeating as necessary.
      dup.or!(mask)
    end

    def or!(mask)
      # Modify the source buffer in place by applying the binary OR operation to the source, using the mask.
      raise(AccessError, 'Buffer has been freed!') if null?
      `op_or(self, self, self.data_view.byteLength, mask)`
      self
    end

    def ^(mask)
      # Generate a new buffer the same size as the source by applying the binary XOR
      # operation to the source, using the mask, repeating as necessary.
      dup.xor!(mask)
    end

    def xor!(mask)
      # Modify the source buffer in place by applying the binary XOR
      # operation to the source, using the mask, repeating as necessary.
      raise(AccessError, 'Buffer has been freed!') if null?
      `op_xor(self, self, self.data_view.byteLength, mask)`
      self
    end

    #
    # other methods
    #

    def <=>(other)
      # Buffers are compared by size and exact contents of the memory they are referencing using memcmp
      return -1 if size < other.size
      return  1 if size > other.size
      %x{
        let a, b, length = self.data_view.byteLength;
        for(let i = 0; i < length; i++) {
          a = self.data_view.getUint8(i);
          b = other.data_view.getUint8(i);
          if (a < b) { return -1; }
          if (a > b) { return 1; }
        }
      }
      0
    end

    def clear(value = 0, offset = 0, length = nil)
      # Fill buffer with value, starting with offset and going for length bytes.
      raise(AccessError, 'Buffer is not writable!') if readonly? || null?
      length ||= size
      %x{
        let uint8_a = new Uint8Array(self.data_view.buffer, self.data_view.byteOffset, self.data_view.byteLength);
        uint8_a.fill(value, offset, length);
      }
      self
    end

    def copy(source, offset = 0, length = nil, source_offset = 0)
      # Efficiently copy from a source IO::Buffer into the buffer,
      # at offset using memcpy. For copying String instances, see set_string.
      raise(AccessError, 'Buffer is not writable!') if readonly? || null?
      raise(ArgumentError, 'source must be a ::IO::Buffer') unless source.is_a?(Buffer)
      length ||= offset + (source.size - source_offset)
      if (offset + length) > size
        raise(ArgumentError, 'Specified offset+length is bigger than the buffer size!')
      end
      `copy_dv(source.data_view, self.data_view, source_offset, offset, length)`
      length
    end

    def each(buffer_type, offset = 0, count = nil)
      # Iterates over the buffer, yielding each value of buffer_type starting from offset.
      raise(AccessError, 'Buffer has been freed!') if null?
      return enum_for(:each, buffer_type, offset, count) unless block_given?
      step = `size_map.get(buffer_type.$to_s())`
      count ||= (size / step).to_i
      len = size - offset
      max = offset + `Math.min(count, len)`
      while offset < max
        yield i, get_value(buffer_type, i)
        offset += step
      end
      self
    end

    def each_byte(offset = 0, count = nil)
      # Iterates over the buffer, yielding each byte starting from offset.
      raise(AccessError, 'Buffer has been freed!') if null?
      return enum_for(:each_byte, offset, count) unless block_given?
      len = size - offset
      max = offset + `Math.min(count, len)`
      while offset < max
        yield `self.data_view.getUint8(offset)`
        offset += 1
      end
      self
    end

    def empty?
      # If the buffer has 0 size
      size == 0
    end

    def free
      # If the buffer references memory, release it back to the operating system.
      raise LockedError if locked?
      @data_view = nil
      @locked = true
    end

    def get_raw_string(offset = 0, length = nil, encoding = nil, ensure_valid = false)
      # not a Ruby method, but used by IO
      raise(AccessError, 'Buffer has been freed!') if null?
      s = size
      length ||= s - offset
      raise(ArgumentError, 'Offset + length is bigger than the buffer size') if offset > s || (offset + length) > s
      raise(ArgumentError, "Offset can't be negative") if offset < 0
      encoding ||= ::Encoding::BINARY
      return encoding.decode(self) if offset == 0 && length == size
      if ensure_valid
        # Ensure the return of a valid last char when byte slicing the buffer with
        # a maximum of 16 tries, meaning to slice up to 16 bytes above limit.
        # Usually the JS TextDecoder is more forgiving than Ruby, so that specs,
        # that test for the splicing of 16 bytes above limit, unfortunately still fail.
        # Even though the TextDecoder may return earlier than Matz Ruby, in JS world
        # the last character is valid, in Matz Ruby world then possibly not.
        max_len = `Math.min(length + 16, s)`
        invalid = true
        res = nil
        while invalid && length < max_len
          begin
            res = encoding.decode!(slice(offset, length))
            invalid = false
          rescue Exception
            length += 1
          end
        end
        if res.nil?
          # unable to read anything valid from the buffer
          return encoding.decode(slice(offset, length))
        end
        res
      else
        encoding.decode(slice(offset, length))
      end
    end

    def get_string(offset = 0, length = nil, encoding = nil)
      # Read a chunk or all of the buffer into a string, in the specified encoding.
      # If no encoding is provided Encoding::BINARY is used.
      encoding ||= ::Encoding::BINARY
      string = get_raw_string(offset, length, encoding)
      %x{
        let n = string.startsWith('\0');
        if (n >= 0) string = string.substring(0, n);
        if (string.encoding != encoding) string = Opal.str(string, encoding.$name());
      }
      string
    end

    def get_value(buffer_type, offset)
      # Read from buffer a value
      raise(AccessError, 'Buffer has been freed!') if null?
      buffer_type_s = buffer_type.to_s
      %x{
        let val = self.data_view['get' + fun_map.get(buffer_type_s)](offset, is_le(buffer_type_s));
        if (typeof(val) === "bigint") { return Number(val); }
        return val;
      }
    end

    def get_values(buffer_types, offset)
      # Similar to get_value, except that it can handle multiple buffer types and returns an array of values.
      raise(AccessError, 'Buffer has been freed!') if null?
      array = []
      buffer_types.each do |buffer_type|
        array << get_value(buffer_type, offset)
        offset += `size_map.get(buffer_type.$to_s())`
      end
      array
    end

    def hexdump(offset = 0, length = nil, _width = nil)
      # Returns a human-readable string representation of the buffer. The exact format is subject to change.
      raise(AccessError, 'Buffer has been freed!') if null?
      length ||= size
      %x{
        let res = []
        for (let i = 0; i < length; i++) {
          res.push(self.data_view.getUint8(offset + i).toString(16).padStart(2, '0'));
        }
        return res.join(' ');
      }
    end

    def initialize_copy(orig)
      %x{
        if (orig.data_view == nil) self.data_view = nil;
        else self.data_view = new DataView(orig.data_view.buffer.slice());
      }
      self
    end

    def inspect
      # #<IO::Buffer 0x000000010198ccd8+11 EXTERNAL READONLY SLICE>
      "##{self.class} #{hexdump(0, `Math.min(8, #{size})`)} INTERNAL #{' READONLY' if readonly?}"
    end

    def locked
      raise LockedError if locked?
      @locked = true
      yield
    ensure
      @locked = false
    end

    def locked?
      @locked == true
    end

    def null?
      `(self.data_view && self.data_view != nil) ? false : true`
    end

    def pread(io, from, length = nil, offset = 0)
      # Read at least length bytes from the io starting at the specified from position,
      # into the buffer starting at offset. If an error occurs, return -errno.
      raise(AccessError, 'Buffer is not writable!') if readonly? || null?
      string = io.pread(length, from)
      set_string(string, offset)
      string
    rescue
      -4 # Errno::EINTR
    end

    def pwrite(io, from, length = nil, offset = 0)
      # Write at least length bytes from the buffer starting at offset,
      # into the io starting at the specified from position. If an error occurs, return -errno.
      io.pwrite(get_string(offset, length), from)
    rescue
      -4 # Errno::EINTR
    end

    def read(io, length = nil, offset = 0)
      # Read at least length bytes from the io, into the buffer starting at offset.
      # If an error occurs, return -errno.
      raise(AccessError, 'Buffer is not writable!') if readonly? || null?
      string = io.read(length)
      set_string(string, offset)
      length
    rescue
      -4 # Errno::EINTR
    end

    def readonly?
      # Frozen strings and read-only files create read-only buffers.
      @readonly
    end

    def resize(new_size)
      # Resizes a buffer to a new_size bytes, preserving its content.
      raise(AccessError, 'Buffer is not writable!') if readonly? || null?
      raise(AccessError, 'Buffer references external memory!') if external?
      raise LockedError if locked?
      if new_size < size || size < new_size
        `self.data_view = new DataView(self.data_view.buffer.transfer(new_size))`
      end
      self
    end

    def set_string(string, offset = 0, length = nil, source_offset = nil)
      # Efficiently copy from a source String into the buffer, at offset using memcpy.
      # Ruby does a byte copy from the C string to the buffer, with the C string most likely
      # being UTF8 encoded. So we do the same, asuming UTF8 for Ruby compatibility,
      # although JavaScript is using UTF16. Efficiently here only happens for UTF8 anyway.
      raise(AccessError, 'Buffer is not writable!') if readonly? || null?
      string = string.byteslice(source_offset) unless source_offset.nil? || source_offset == 0
      bytes = string.bytes
      strg_dv = `new DataView((new Uint8Array(bytes)).buffer)`
      %x{
        if (typeof(length) !== "number") length = strg_dv.byteLength;
        length = Math.min(strg_dv.byteLength, self.data_view.byteLength);
        copy_dv(strg_dv, self.data_view, 0, offset, length);
      }
      length
    end

    def set_value(buffer_type, offset, value)
      # Write to a buffer a value of type at offset.
      raise(AccessError, 'Buffer is not writable!') if readonly? || null?
      buffer_type_s = buffer_type.to_s
      %x{
        let fun = 'set' + fun_map.get(buffer_type_s);
        if (fun[3] === 'B') { value = BigInt(value); }
        self.data_view[fun](offset, value, is_le(buffer_type_s));
      }
      offset + `size_map.get(buffer_type_s)`
    end

    def set_values(buffer_types, offset, values)
      # Write values of buffer_types at offset to the buffer. buffer_types should be an array
      # of symbols as described in get_value. values should be an array of values to write.
      raise(AccessError, 'Buffer is not writable!') if readonly? || null?
      raise(ArgumentError, 'Argument buffer_types must be an array!') unless buffer_types.is_a?(Array)
      raise(ArgumentError, 'Argument values must be an array!') unless values.is_a?(Array)
      raise(ArgumentError, 'Arrays buffer_types and values must have the same length!') unless buffer_types.size == values.size
      buffer_types.each_with_index do |buffer_type, idx|
        offset = set_value(buffer_type, offset, values[idx])
      end
      offset
    end

    def size
      # Returns the size of the buffer that was explicitly set (on creation with ::new or on resize),
      # or deduced on buffer’s creation from string or file.
      return 0 if null?
      `self.data_view.byteLength`
    end

    def slice(offset = 0, length = nil)
      # Produce another IO::Buffer which is a slice (or view into) the current one
      # starting at offset bytes and going for length bytes.
      raise(AccessError, 'Buffer has been freed!') if null?
      raise(ArgumentError, 'offset must be >= 0') if offset < 0
      length ||= size - offset
      raise(ArgumentError, 'length must be >= 0') if length < 0
      end_pos = offset + length
      raise(ArgumentError, "Index #{end_pos} out buffer bounds") if end_pos > size
      io_buffer = Buffer.new(nil, EXTERNAL)
      `io_buffer.data_view = new DataView(self.data_view.buffer, self.data_view.byteOffset + offset, length)`
      `io_buffer.readonly = true` if readonly?
      io_buffer
    end

    def to_s
      inspect
    end

    def transfer
      # Transfers ownership of the underlying memory to a new buffer, causing the current buffer to become uninitialized.
      raise(AccessError, 'Buffer has been freed!') if null?
      raise(LockedError, 'Cannot transfer ownership of locked buffer!') if locked?
      io_buffer = Buffer.new(nil)
      `io_buffer.data_view = self.data_view`
      `io_buffer.readonly = true` if readonly?
      @data_view = nil
      io_buffer
    end

    def valid?
      # Returns whether the buffer buffer is accessible.
      !null?
    end

    def values(buffer_type, offset = 0, count = nil)
      # Returns an array of values of buffer_type starting from offset.
      array = []
      step = `size_map.get(buffer_type.$to_s())`
      count ||= (size / step).to_i
      while count > 0
        array << get_value(buffer_type, offset)
        offset += step
        count -= 1
      end
      array
    end

    def write(io, length = nil, offset = 0)
      # Write at least length bytes from the buffer starting at offset, into the io. If an error occurs, return -errno.
      raise(AccessError, 'Buffer has been freed!') if null?
      length ||= size - offset
      io.write(get_string(offset, length))
    end

    #
    # methods for Opal convenience and speed
    # these methods do not check Buffer state or validate anything
    #

    def get_byte(offset)
      `self.data_view.getUint8(offset)`
    end

    def set_byte(offset, value)
      `self.data_view.setUint8(offset, value)`
    end
  end
end
