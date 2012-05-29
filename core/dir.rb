class Dir
  def self.getwd
    ""
  end

  def self.pwd
    ""
  end

  def self.[](*globs)
    %x{
      var result = [], files = factories;

      for (var i = 0, ii = globs.length; i < ii; i++) {
        var glob = globs[i];

        var re = fs_glob_to_regexp(#{ File.expand_path `glob` });

        for (var file in files) {
          if (re.exec(file)) {
            result.push(file);
          }
        }
      }

      return result;
    }
  end

  %x(
    function fs_glob_to_regexp(glob) {
      var parts  = glob.split(''),
          length = parts.length,
          result = '';

      var opt_group_stack = 0;

      for (var i = 0; i < length; i++) {
        var cur = parts[i];

        switch (cur) {
          case '*':
            if (parts[i + 1] === '*' && parts[i + 2] === '/') {
              result += '.*';
              i += 2;
            }
            else {
              result += '[^/]*';
            }
            break;

          case '.':
            result += '\\\\';
            result += cur;
            break;

          case ',':
            if (opt_group_stack) {
              result += '|';
            }
            else {
              result += ',';
            }
            break;

          case '{':
            result += '(';
            opt_group_stack++;
            break;

          case '}':
            if (opt_group_stack) {
              result += ')';
              opt_group_stack--;
            }
            else {
              result += '}'
            }
            break;

          default:
            result += cur;
        }
      }

      return new RegExp('^' + result + '$');
    }
  )
end