class File
  def self.read(path)
    %x{
      const body = std.loadFile(path);
      if (body === null) {
        throw new Error(`Unable to read "${path}"`);
      }
      return body;
    }
  end
end
