module Base64
  %x{
    var encode = Opal.global.btoa;
    var decode = Opal.global.atob;
  }

  def self.decode64(string)
    `decode(string.replace(/\r?\n/g, ''))`
  end

  def self.encode64(string)
    `encode(string).replace(/(.{60})/g, "$1\n").replace(/([^\n])$/g, "$1\n")`
  end

  def self.strict_decode64(string)
    `decode(string)`
  end

  def self.strict_encode64(string)
    `encode(string)`
  end

  def self.urlsafe_decode64(string)
    `decode(string.replace(/\-/g, '+').replace(/_/g, '/'))`
  end

  def self.urlsafe_encode64(string, padding: true)
    str = `encode(string).replace(/\+/g, '-').replace(/\//g, '_')`
    str = str.delete('=') unless padding
    str
  end
end
