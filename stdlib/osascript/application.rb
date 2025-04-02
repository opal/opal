# backtick_javascript: true

class Application
  def self.currentApplication
    new(nil)
  end

  def initialize(identifier)
    @native_application = if identifier.nil?
      `Application.currentApplication()`
    else
      `Application(identifier)`
    end
  end

  def method_missing(name, *args)
    name_s = name.to_s
    if name_s.end_with?('=')
      %x{
        name_s = name_s.substring(0, name_s.length - 1);
        self.native_application[name_s] = args[0];
      }
    else
      if args.size == 0
        `self.native_application[name_s]()`
      else
        `self.native_application[name_s](...args)`
      end
    end
  end
end
