class File < IO
  Separator = SEPARATOR = '/'
  ALT_SEPARATOR = '\\'
  PATH_SEPARATOR = ':'
  # Assuming case insenstive filesystem
  FNM_SYSCASE = 0

  class << self
    def expand_path(path, basedir = nil)
      path = [basedir, path].compact.join(SEPARATOR)
      parts = path.split(SEPARATOR)
      new_parts = []
      parts[0] = Dir.home if parts.first == '~'
      parts[0] = Dir.pwd if parts.first == '.'

      parts.each do |part|
        if part == '..'
          new_parts.pop
        else
          new_parts << part
        end
      end
      new_parts.join(SEPARATOR)
    end
    alias realpath expand_path

    %x{
      function $coerce_to_path(path) {
        if (#{Opal.truthy?(`path`.respond_to?(:to_path))}) {
          path = path.$to_path();
        }

        path = #{Opal.coerce_to!(`path`, String, :to_str)};

        return path;
      }

      function inc(a) {
        return a.substring(1, a.length);
      }

      function lastSeparator(path) {
        var tmp, last;

        while (path.length > 0) {
          if (isDirSep(path)) {
            tmp = path;
            path = inc(path);

            while (path.length > 0 && isDirSep(path)) {
              path = inc(path);
            }
            if (!path) {
              break;
            }
            last = tmp;
          }
          else {
            path = inc(path);
          }
        }

        return last;
      }

      function isDirSep(sep) {
        var sep = #{SEPARATOR}, alt_sep = #{ALT_SEPARATOR}
        return sep.charAt(0) === sep || (alt_sep !== nil && sep.charAt(0) === alt_sep);
      }

      function skipRoot(path) {
        while (path.length > 0 && isDirSep(path)) {
          path = inc(path);
        }
        return path;
      }
    }

    def dirname(path)
      %x{
        if (path === nil) {
          #{raise TypeError, 'no implicit conversion of nil into String'}
        }
        if (#{path.respond_to?(:to_path)}) {
          path = #{path.to_path};
        }
        if (!path.$$is_string) {
          #{raise TypeError, "no implicit conversion of #{path.class} into String"}
        }

        var root, p;

        root = skipRoot(path);

        // if (root > name + 1) in the C code
        if (root.length == 0) {
          path = path.substring(path.length - 1, path.length);
        }
        else if (root.length - path.length < 0) {
          path = path.substring(path.indexOf(root)-1, path.length);
        }

        p = lastSeparator(root);
        if (!p) {
          p = root;
        }
        if (p === path) {
          return '.';
        }
        return path.substring(0, path.length - p.length);
      }
    end

    def basename(name, suffix=nil)
      sep_chars = nil
      %x{
        if (#{ALT_SEPARATOR} === nil) {
          sep_chars = #{SEPARATOR}
        } else {
          sep_chars = #{SEPARATOR+ALT_SEPARATOR}
        }

        sep_chars = Opal.escape_regexp(sep_chars);
        name = $coerce_to_path(name);

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
      raise TypeError, 'no implicit conversion of nil into String' if path.nil?
      path = path.to_path if path.respond_to?(:to_path)
      raise TypeError, "no implicit conversion of #{path.class} into String" unless path.is_a?(String)
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
