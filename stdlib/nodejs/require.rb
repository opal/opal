require 'opal-parser'

module Kernel
  def require path
    name = `$opal.normalize_loadable_path(#{path})`

    if `!$opal.modules[#{name}]`
      ruby = File.read(path)
      js = Opal.compile(ruby, requirable: true, file: name)
      `eval(#{js})`
    end

    `$opal.require(#{name})`
  end

  def load path
    name = `$opal.normalize_loadable_path(#{path})`

    if `!$opal.modules[#{name}]`
      ruby = File.read(path)
      js = Opal.compile(ruby, requirable: true, file: name)
      `eval(js)`
    end

    `$opal.load(#{name})`
  end
end
