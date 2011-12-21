class Dir
  def self.getwd
    `FS_CWD`
  end

  def self.pwd
    `FS_CWD`
  end

  def self.[](*globs)
    %x{
      var result = [], files = LOADER_FACTORIES;

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
end
