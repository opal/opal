class File < IO
  Separator = SEPARATOR = '/'
  ALT_SEPARATOR = nil
  PATH_SEPARATOR = ':'
  # Assuming case insenstive filesystem
  FNM_SYSCASE = 0

  class << self
    def expand_path(path, basedir = nil)
      sep = SEPARATOR
      new_parts = []

      if path.start_with?('~') || (basedir && basedir.start_with?('~'))
        home = Dir.home
        raise(ArgumentError, "couldn't find HOME environment -- expanding `~'") unless home
        raise(ArgumentError, "non-absolute home") unless home.start_with?(sep)
        home += sep
        path = path.sub(/^\~(?:#{sep}|$)/, home)
        basedir = basedir.sub(/^\~(?:#{sep}|$)/, home) if basedir
      end

      basedir = Dir.pwd unless basedir
      path_abs = path.start_with?(sep)
      basedir_abs = basedir.start_with?(sep)

      if path_abs
        parts = path.split(sep)
        leading_sep = path.sub(/^([#{sep}]+).*$/, '\1')
        abs = true
      else
        parts = basedir.split(sep) + path.split(sep)
        leading_sep = basedir.sub(/^([#{sep}]+).*$/, '\1')
        abs = basedir_abs
      end

      parts.each do |part|
        next if part.nil?
        next if part == ''  && (!new_parts.empty? || abs)
        next if part == '.' && (!new_parts.empty? || abs)
        if part == '..'
          new_parts.pop
        else
          new_parts << part
        end
      end

      new_parts.unshift '.' if !abs && parts[0] != '.'

      new_path = new_parts.join(sep)
      new_path = leading_sep+new_path if abs
      new_path
    end
    alias realpath expand_path

    %x{
      // Coerce a given path to a path string using #to_path and #to_str
      function $coerce_to_path(path) {
        if (#{Opal.truthy?(`path`.respond_to?(:to_path))}) {
          path = path.$to_path();
        }

        path = #{Opal.coerce_to!(`path`, String, :to_str)};

        return path;
      }

      // Return a RegExp compatible char class
      function $sep_chars() {
        if (#{ALT_SEPARATOR} === nil) {
          return Opal.escape_regexp(#{SEPARATOR});
        } else {
          return Opal.escape_regexp(#{SEPARATOR+ALT_SEPARATOR});
        }
      }
    }

    def dirname(path)
      sep_chars = `$sep_chars()`
      path = `$coerce_to_path(path)`
      %x{
        var absolute = path.match(new RegExp(#{"^[#{sep_chars}]"}));

        path = path.replace(new RegExp(#{"[#{sep_chars}]+$"}), ''); // remove trailing separators
        path = path.replace(new RegExp(#{"[^#{sep_chars}]+$"}), ''); // remove trailing basename
        path = path.replace(new RegExp(#{"[#{sep_chars}]+$"}), ''); // remove final trailing separators

        if (path === '') {
          return absolute ? '/' : '.';
        }

        return path;
      }
    end

    def basename(name, suffix=nil)
      sep_chars = `$sep_chars()`
      name = `$coerce_to_path(name)`
      %x{
        if (name.length == 0) {
          return name;
        }

        if (suffix !== nil) {
          suffix = #{Opal.coerce_to!(suffix, String, :to_str)}
        } else {
          suffix = null;
        }

        name = name.replace(new RegExp(#{"(.)[#{sep_chars}]*$"}), '$1');
        name = name.replace(new RegExp(#{"^(?:.*[#{sep_chars}])?([^#{sep_chars}]+)$"}), '$1');

        if (suffix === ".*") {
          name = name.replace(/\.[^\.]+$/, '');
        } else if(suffix !== null) {
          suffix = Opal.escape_regexp(suffix);
          name = name.replace(new RegExp(#{"#{suffix}$"}), '');
        }

        return name;
      }
    end

    def extname(path)
      `path = $coerce_to_path(path);`
      filename = basename(path)
      return '' if filename.empty?
      last_dot_idx = filename[1..-1].rindex('.')
      # extension name must contains at least one character .(something)
      (last_dot_idx.nil? || last_dot_idx + 1 == filename.length - 1) ? '' : filename[(last_dot_idx + 1)..-1]
    end

    def exist? path
      `Opal.modules[#{path}] != null`
    end
    alias exists? exist?

    def directory?(path)
      files = []
      %x{
        for (var key in Opal.modules) {
          #{files}.push(key)
        }
      }
      path = path.gsub(%r{(^.#{SEPARATOR}+|#{SEPARATOR}+$)})
      file = files.find do |file|
        file =~ /^#{path}/
      end
      file
    end

    def join(*paths)
      if paths.length == 0
        return ''
      end
      result = ''
      paths = paths.flatten.each_with_index.map do |item, index|
        if index == 0 && item.empty?
          SEPARATOR
        elsif paths.length == index + 1 && item.empty?
          SEPARATOR
        else
          item
        end
      end
      paths = paths.reject { |path| path.empty? }
      paths.each_with_index do |item, index|
        next_item = paths[index + 1]
        if next_item.nil?
          result = "#{result}#{item}"
        else
          if item.end_with?(SEPARATOR) && next_item.start_with?(SEPARATOR)
            item = item.sub(%r{#{SEPARATOR}+$}, '')
          end
          if item.end_with?(SEPARATOR) || next_item.start_with?(SEPARATOR)
            result = "#{result}#{item}"
          else
            result = "#{result}#{item}#{SEPARATOR}"
          end
        end
      end
      result
    end

    def split(path)
      path.split(SEPARATOR)
    end
  end
end
