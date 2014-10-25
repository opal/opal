require 'opal-parser'

module Kernel
  def __prepare_require__(path)
    name = `Opal.normalize_loadable_path(#{path})`
    full_path = name.end_with?('.rb') ? name : name+'.rb'

    if `!Opal.modules[#{name}]`
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

  def require(path)
    `Opal.require(#{__prepare_require__(path)})`
  end

  def load path
    `Opal.load(#{__prepare_require__(path)})`
  end
end
