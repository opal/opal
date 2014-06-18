require 'opal-parser'

module Kernel
  def require path
    name = `$opal.normalize_loadable_path(#{path})`
    `console.log('require', #{name}, !!$opal.modules[#{name}])`

    if `!$opal.modules[#{name}]`
      ruby = File.read(path)
      js = Opal.compile(ruby, requirable: true, file: name)
      `eval(#{js})`
    end
    `console.log('postrequire', #{name}, !!$opal.modules[#{name}])`

    `$opal.require(#{name})`
  end

  def load path
    name = `$opal.normalize_loadable_path(#{path})`
    `console.log('load', #{name}, !!$opal.modules[#{name}])`

    if `!$opal.modules[#{name}]`
      `console.log('exist', #{File.exist?('./'+path)}, 'keys', Object.keys($opal.modules));`
      ruby = File.read(path)
      p [path, name, ruby.size]
      js = Opal.compile(ruby, requirable: true, file: name)
      `eval(js)`
    end
    `console.log('postload', #{name}, !!$opal.modules[#{name}])`
    `$opal.load(#{name})`
  end
end
