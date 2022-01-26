# frozen_string_literal: true

module URI
  def self.decode_www_form(str, enc = undefined, separator: '&', use__charset_: false, isindex: false)
    raise ArgumentError, "the input of #{name}.#{__method__} must be ASCII only string" unless str.ascii_only?

    %x{
      var ary = [], key, val;
      if (str.length == 0)
        return ary;
      if (enc)
        #{enc = Encoding.find(enc)};

      var parts = str.split(#{separator});
      for (var i = 0; i < parts.length; i++) {
        var string = parts[i];
        var splitIndex = string.indexOf('=')

        if (splitIndex >= 0) {
          key = string.substr(0, splitIndex);
          val = string.substr(splitIndex + 1);
        } else {
          key = string;
          val = '';
        }

        if (isindex) {
          if (splitIndex < 0) {
            key = '';
            val = string;
          }
          isindex = false;
        }

        key = decodeURIComponent(key.replace(/\+/g, ' '));
        if (val) {
          val = decodeURIComponent(val.replace(/\+/g, ' '));
        } else {
          val = '';
        }

        if (enc) {
          key = #{`key`.force_encoding(enc)}
          val = #{`val`.force_encoding(enc)}
        }

        ary.push([key, val]);
      }

      return ary;
    }
  end
end
