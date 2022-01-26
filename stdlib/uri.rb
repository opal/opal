# frozen_string_literal: true

module URI
  def self.decode_www_form(str, separator: '&', isindex: false)
    %x{
      var ary = [];
      if (str.length == 0) {
        return ary;
      }
      var parts = str.split(#{separator});
      for (var i = 0; i < parts.length; i++) {
        var string = parts[i];
        var comps = string.split('=');
        var key = comps[0];
        var val = comps[1];
        if (#{isindex}) {
          if (comps.length < 2) {
            val = key;
            key = '';
          }
        }

        key = decodeURIComponent(key.replace(/\+/g, ' '));
        if (val) {
          val = decodeURIComponent(val.replace(/\+/g, ' '));
        } else {
          val = '';
        }
        ary.push([key, val]);
      }
      return ary;
    }
  end
end
