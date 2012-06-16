module JSON
  def self.parse(source)
    `return to_opal(json_parse(source));`
  end

  %x{
    var json_parse;
    var cx = /[\\u0000\\u00ad\\u0600-\\u0604\\u070f\\u17b4\\u17b5\\u200c-\\u200f\\u2028-\\u202f\\u2060-\\u206f\\ufeff\\ufff0-\\uffff]/g;

    if (typeof JSON !== 'undefined') {
      json_parse = JSON.parse;
    }
    else {
      var evaluator = window.eval;
      json_parse = function(text) {
        text = String(text);
        cx.lastIndex = 0;

        if (cx.test(text)) {
          text = text.replace(cx, function(a) {
            return '\\\\u' + ('0000' + a.charCodeAt(0).toString(16)).slice(-4);
          });
        }

        if (/^[\\],:{}\\s]*$/
                    .test(text.replace(/\\\\(?:["\\\\\\/bfnrt]|u[0-9a-fA-F]{4})/g, '@')
                        .replace(/"[^"\\\\\\n\\r]*"|true|false|null|-?\\d+(?:\\.\\d*)?(?:[eE][+\\-]?\\d+)?/g, ']')
                        .replace(/(?:^|:|,)(?:\\s*\\[)+/g, ''))) {

                return evaluator('(' + text + ')');
        }

        throw new Error("JSON.parse");
      };
    }


    function to_opal(value) {
      switch (typeof value) {
        case 'string':
          return value;

        case 'number':
          return value;

        case 'boolean':
          return !!value;

        case 'null':
          return nil;

        case 'object':
          if (!value) return nil;

          if (Object.prototype.toString.apply(value) === '[object Array]') {
            var arr = [];

            for (var i = 0, ii = value.length; i < ii; i++) {
              arr.push(to_opal(value[i]));
            }

            return arr;
          }
          else {
            var hash = #{ {} }, v, map = hash.map;

            for (var k in value) {
              if (__hasOwn.call(value, k)) {
                v = to_opal(value[k]);
                map[k] = [k, v];
              }
            }
          }

          return hash;
      }
    };
  }
end