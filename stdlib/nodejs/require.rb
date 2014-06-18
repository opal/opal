require 'opal-parser'

module Kernel
  def __prepare_require__(path)
    name = `$opal.normalize_loadable_path(#{path})`
    full_path = name.end_with?('.rb') ? name : name+'.rb'

    if `!$opal.modules[#{name}]`
      ruby = File.read(full_path)
      compiler = Opal::Compiler.new(ruby, requirable: true, file: name)
      js = compiler.compile
      compiler.requires.each do |sub_path|
        __prepare_require__(sub_path)
      end
      `eval(#{js})`
    end

    name
  rescue => e
    raise [path, name, full_path].inspect+e.message
  end

  def require path
    name = __prepare_require__(path)
    `$opal.require(#{name})`
  end

  def load path
    name = __prepare_require__(path)
    `$opal.load(#{name})`
  end
end
