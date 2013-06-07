module Browser
  module LocalStorage
    def self.[](key)
      %x{
        var val = localStorage.getItem(key);
        return val === null ? null : val;
      }
    end

    def self.[]=(key, value)
      `localStorage.setItem(key, value)`
    end

    def self.clear
      `localStorage.clear()`
      self
    end

    def self.delete(key)
      %x{
        var val = localStorage.getItem(key);
        localStorage.removeItem(key);
        return val === null ? null : val;
      }
    end
  end
end
