class File
  # Regexp to split path into dirname, basename and extname
  PATH_RE = /^(.+\/(?!$)|\/)?((?:.+?)?(\.[^.]*)?)$/

  def self.expand_path(path, base = undefined)
    %x{
      if (!base) {
        base = '';
      }

      path = #{ join(base, path) };

      var parts = path.split('/'), result = [], path;

      for (var i = 0, ii = parts.length; i < ii; i++) {
        part = parts[i];

        if (part === '..') {
          result.pop();
        }
        else if (part === '.' || part === '') {
          // ignore?
        }
        else {
          result.push(part);
        }
      }

      return result.join('/');
    }
  end

  def self.join(*paths)
    %x{
      var result = [];

      for (var i = 0, length = paths.length; i < length; i++) {
        var part = paths[i];

        if (part != '') {
          result.push(part);
        }
      }

      return result.join('/');
    }
  end

  def self.dirname(path)
    %x{
      var dirname = #{PATH_RE}.exec(path)[1];

      if (!dirname) {
        return '.';
      }
      else if (dirname === '/') {
        return dirname;
      }
      else {
        return dirname.substring(0, dirname.length - 1);
      }
    }
  end

  def self.extname(path)
    %x{
      var extname = #{PATH_RE}.exec(path)[3];

      if (!extname || extname === '.') {
        return '';
      }
      else {
        return extname;
      }
    }
  end

  def self.basename(path, suffix)
    ""
  end

  def self.exist?(path)
    `!!factories[#{ expand_path path }]`
  end
end