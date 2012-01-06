class File
  def self.expand_path(path, base = undefined)
    %x{
      if (!base) {
        if (path.charAt(0) !== '/') {
          base = FS_CWD;
        }
        else {
          base = '';
        }
      }

      path = #{ join(base, path) };

      var parts = path.split('/'), result = [], path;

      // initial '/'
      if (parts[0] === '') {
        result.push('');
      }

      for (var i = 0, ii = parts.length; i < ii; i++) {
        part = parts[i];

        if (part === '..') {
          result.pop();
        }
        else if (part === '.' || part === '') {

        }
        else {
          result.push(part);
        }
      }

      return result.join('/');
    }
  end

  def self.join(*paths)
    `paths.join('/')`
  end

  def self.dirname(path)
    %x{
      var dirname = PATH_RE.exec(path)[1];

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
      var extname = PATH_RE.exec(path)[3];

      if (!extname || extname === '.') {
        return '';
      }
      else {
        return extname;
      }
    }
  end

  def self.basename(path, suffix)
    `$opal.fs.basename(path, suffix)`
  end

  def self.exist?(path)
    `opal.loader.factories[#{ expand_path path }] ? true : false`
  end
end
