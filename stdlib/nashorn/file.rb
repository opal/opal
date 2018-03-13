class File
  def self.read(path)
    %x(
        var Paths = Java.type('java.nio.file.Paths');
        var Files = Java.type('java.nio.file.Files');
        var lines = Files.readAllLines(Paths.get(path), Java.type('java.nio.charset.StandardCharsets').UTF_8);
        var data = [];
        lines.forEach(function(line) { data.push(line); });
        return data.join("\n");
      )
  end

  def self.file?(path)
    %x{
      var Files = Java.type('java.nio.file.Files');
      return Files.exists(path) && Files.isRegularFile(path);
    }
  end

  def self.readable?(path)
    %x{
      var Files = Java.type('java.nio.file.Files');
      return Files.exists(path) && Files.isReadable(path);
    }
  end
end
