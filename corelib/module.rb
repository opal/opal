# Implements the core functionality of modules. This is inherited from
# by instances of {Class}, so these methods are also available to
# classes.
class Module
  def self.constants
    # TODO: how to get module constants?

    raise NotImplementedError, '.constants has not been implemented yet'
  end

  def self.nesting
    # TODO: how to implement this?

    raise NotImplementedError, '.nesting has not been implemented yet'
  end

  def self.new
    # TODO: how to create a new module?

    raise NotImplementedError, '.new has not been implemented yet'
  end

  def === (object)
    object.kind_of? self
  end

  def alias_method (new_name, old_name)
    `rb_alias_method(self, #{new_name.to_s}, #{old_name.to_s});`

    self
  end

  def attr_accessor (*attrs)
    attr_reader *attrs
    attr_writer *attrs
  end

  def attr_reader(*attrs)
    attrs.each do |a|
      `var name = #{a.to_s};
      rb_define_method(self, name, function (self) {
        return self[name] === undefined ? nil : self[name];
      });`
    end

    nil
  end

  def attr_writer (*attrs)
    attrs.each do |a|
      `
        var name = #{a.to_s};
        rb_define_method(self, name + '=', function (self, val) {
          return self[name.substr(0, name.length)] = val;
        });
      `
    end

    nil
  end

  def define_method(name, method = nil, &block)
    raise LocalJumpError, 'no block given' unless block_given?

    `VM.dm(self, #{name.to_s}, method || block)`

    nil
  end

  def public_instance_methods (include_super = true)
    `self.$methods`
  end

  def instance_methods
    `self.$methods`
  end

  def ancestors
    `
      var result = [], parent = self;

      while (parent) {
        if (parent.$f & FL_SINGLETON) {
          // nothing?
        }
        else {
          result.push(parent);
        }

        parent = parent.$s;
      }

      return result;
    `
  end

  def const_set(id, value)
    `return rb_const_set(self, #{id.to_s}, value);`
  end

  def class_eval(str = nil, &block)
    if block_given?
      `block(self)`
    else
      raise 'need to compile str'
    end
  end

  alias_method :module_eval, :class_eval

  def extend(*mods)
    modes.each {|mod|
      `rb_extend_module(self, mod);`
    }

    self
  end

  def name
    `self.__classid__`
  end

  alias_method :to_s, :name
end

class Object
  include Kernel
end
