# Implements the core functionality of modules. This is inherited from
# by instances of {Class}, so these methods are also available to
# classes.
class Module

  def name
    `return self.__classid__;`
  end

  def ===(obj)
    obj.kind_of? self
  end

  def define_method(method_id, &block)
    raise LocalJumpError, "no block given" unless block_given?
    `$runtime.define_method(self, #{method_id.to_s}, block)`
    nil
  end

  def attr_accessor(*attrs)
    attr_reader *attrs
    attr_writer *attrs
  end

  def attr_reader(*attrs)
    `for (var i = 0; i < attrs.length; i++) {
      var attr = attrs[i];
      var method_id = #{`attr`.to_s};

      $runtime.define_method(self, method_id,
            new Function('var iv = this["@' + method_id + '"]; return iv === undefined ? nil : iv;'));
    }

    return nil;`
  end

  def attr_writer(*attrs)
    `for (var i = 0; i < attrs.length; i++) {
      var attr = attrs[i];
      var method_id = #{`attr`.to_s};

      $runtime.define_method(self, method_id + '=',
        new Function('self', 'val', 'return self["@' + method_id + '"] = val;'));

    }

    return nil;`
  end

  def alias_method(new_name, old_name)
    `$runtime.alias_method(self, #{new_name.to_s}, #{old_name.to_s});`
    self
  end

  def to_s
    `return self.__classid__;`
  end

  def const_set(id, value)
    `return rb_vm_cs(self, #{id.to_s}, value);`
  end

  def class_eval(str = nil, &block)
    if block_given?
      `block.call(self)`
    else
      raise "need to compile str"
    end
  end

  def module_eval(str = nil, &block)
    class_eval str, &block
  end


  def protected
    self
  end

  def extend(mod)
    `$runtime.extend_module(self, mod)`
    nil
  end
end

