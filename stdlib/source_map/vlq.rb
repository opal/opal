module SourceMap
  # Public: Base64 VLQ encoding
  #
  # Adopted from ConradIrwin/ruby-source_map
  #   https://github.com/ConradIrwin/ruby-source_map/blob/master/lib/source_map/vlq.rb
  #
  # Resources
  #
  #   http://en.wikipedia.org/wiki/Variable-length_quantity
  #   https://docs.google.com/document/d/1U1RGAehQwRypUTovF1KRlpiOFze0b-_2gc6fAH0KY0k/edit
  #   https://github.com/mozilla/source-map/blob/master/lib/source-map/base64-vlq.js
  #
  module VLQ
    VLQ_BASE_SHIFT = 5
    VLQ_BASE = 1 << VLQ_BASE_SHIFT
    VLQ_BASE_MASK = VLQ_BASE - 1
    VLQ_CONTINUATION_BIT = VLQ_BASE

    BASE64_DIGITS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'.split('')
    BASE64_VALUES = (0...64).inject({}) { |h, i| h[BASE64_DIGITS[i]] = i; h }

    # Public: Encode a list of numbers into a compact VLQ string.
    #
    # ary - An Array of Integers
    #
    # Returns a VLQ String.
    def self.encode(ary)
      result = []
      ary.each do |n|
        vlq = n < 0 ? ((-n) << 1) + 1 : n << 1
        begin
          digit  = vlq & VLQ_BASE_MASK
          vlq  >>= VLQ_BASE_SHIFT
          digit |= VLQ_CONTINUATION_BIT if vlq > 0
          result << BASE64_DIGITS[digit]
        end while vlq > 0
      end
      result.join
    end

    # Public: Decode a VLQ string.
    #
    # str - VLQ encoded String
    #
    # Returns an Array of Integers.
    def self.decode(str)
      result = []
      chars = str.split('')
      while chars.any?
        vlq = 0
        shift = 0
        continuation = true
        while continuation
          char = chars.shift
          raise ArgumentError unless char
          digit = BASE64_VALUES[char]
          continuation = false if (digit & VLQ_CONTINUATION_BIT) == 0
          digit &= VLQ_BASE_MASK
          vlq   += digit << shift
          shift += VLQ_BASE_SHIFT
        end
        result << (vlq & 1 == 1 ? -(vlq >> 1) : vlq >> 1)
      end
      result
    end

    # Public: Encode a mapping array into a compact VLQ string.
    #
    # ary - Two dimensional Array of Integers.
    #
    # Returns a VLQ encoded String seperated by , and ;.
    def self.encode_mappings(ary)
      ary.map { |group|
        group.map { |segment|
          encode(segment)
        }.join(',')
      }.join(';')
    end

    # Public: Decode a VLQ string into mapping numbers.
    #
    # str - VLQ encoded String
    #
    # Returns an two dimensional Array of Integers.
    def self.decode_mappings(str)
      mappings = []

      str.split(';').each_with_index do |group, index|
        mappings[index] = []
        group.split(',').each do |segment|
          mappings[index] << decode(segment)
        end
      end

      mappings
    end
  end
end
