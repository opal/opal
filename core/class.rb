class Class
  def self.new(sup = Object, &block)
    %x{
      function AnonClass(){};
      var klass   = boot_class(sup, AnonClass)
      klass._name = nil;

      sup.$inherited(klass);

      if (block !== nil) {
        block.call(klass);
      }

      return klass;
    }
  end

  def allocate
    %x{
      var obj = new #{self};
      obj._id = unique_id++;
      return obj;
    }
  end

  def alias_method(newname, oldname)
    `#{self}.prototype['$' + newname] = #{self}.prototype['$' + oldname]`
    self
  end

  def ancestors
    %x{
      var parent = #{self},
          result = [];

      while (parent) {
        result.push(parent);
        parent = parent._super;
      }

      return result;
    }
  end

  def append_features(klass)
    %x{
      var module = #{self};

      if (!klass.$included_modules) {
        klass.$included_modules = [];
      }

      for (var idx = 0, length = klass.$included_modules.length; idx < length; idx++) {
        if (klass.$included_modules[idx] === module) {
          return;
        }
      }

      klass.$included_modules.push(module);

      if (!module.$included_in) {
        module.$included_in = [];
      }

      module.$included_in.push(klass);

      var donator   = module.prototype,
          prototype = klass.prototype,
          methods   = module._methods;

      for (var i = 0, length = methods.length; i < length; i++) {
        var method = methods[i];
        prototype[method] = donator[method];
      }

      if (klass.$included_in) {
        klass._donate(methods.slice(), true);
      }
    }

    self
  end

  # handled by parser
  def attr_accessor(*); end

  alias attr_reader attr_accessor
  alias attr_writer attr_accessor
  alias attr attr_accessor

  def define_method(name, &block)
    %x{
      if (block === nil) {
        no_block_given();
      }

      var jsid    = '$' + name;
      block._jsid = jsid;
      block._sup  = #{self}.prototype[jsid];

      #{self}.prototype[jsid] = block;
      #{self}._donate([jsid]);

      return nil;
    }
  end

  def include(*mods)
    %x{
      var i = mods.length - 1, mod;
      while (i >= 0) {
        mod = mods[i];
        i--;

        if (mod === #{self}) {
          continue;
        }

        #{ `mod`.append_features self };
        #{ `mod`.included self };
      }

      return #{self};
    }
  end

  def instance_methods(include_super = false)
    %x{
      var methods = [], proto = #{self}.prototype;

      for (var prop in #{self}.prototype) {
        if (!include_super && !proto.hasOwnProperty(prop)) {
          continue;
        }

        if (prop.charAt(0) === '$') {
          methods.push(prop.substr(1));
        }
      }

      return methods;
    }
  end

  def included(mod)
  end

  def inherited(cls)
  end

  def module_eval(&block)
    %x{
      if (block === nil) {
        no_block_given();
      }

      return block.call(#{self});
    }
  end

  alias class_eval module_eval

  def name
    `#{self}._name`
  end

  def new(*args, &block)
    %x{
      var obj = new #{self};
      obj._id = unique_id++;
      obj.$initialize._p  = block;

      obj.$initialize.apply(obj, args);
      return obj;
    }
  end

  def public(*)
  end

  alias private public
  alias protected public

  def singleton_class
    %x{
      if (#{self}._singleton) {
        return #{self}._singleton;
      }

      var meta = new __opal.Class;
      #{self}._singleton = meta;
      meta.prototype = #{self};

      return meta;
    }
  end

  def superclass
    %x{
      return #{self}._super || nil;
    }
  end
end