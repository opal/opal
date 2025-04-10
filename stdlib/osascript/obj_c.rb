# frozen_string_literal: true
# backtick_javascript: true
require 'native'
require 'osascript/application'
require 'osascript/library'
module ::Kernel
  def Application(identifier)
    ::Application.new(identifier)
  end

  def Library(name)
    ::Library.new(name)
  end

  def Path(str)
    `Path(str)`
  end

  def Ref(arg)
    ::ObjectiveCObject.new(arg.nil? ? `Ref()` : `Ref(arg)`)
  end

  def delay(i)
    `delay(i)`
  end

  def method_missing(name, *args)
    super
  rescue => e
    name_s = name.to_s
    if `typeof($[name_s] === "function")`
      res = nil
      %x{
        res = $[name_s](...args);
        if (res == $(res)) {
          // got a ObjectiveC object
          res = #{::ObjectiveCObject.new(`res`)};
        }
      }
      return res
    end
    raise e
  end
end

class ::Module
  def const_missing(name)
    if self == ::Object
      name_s = name.to_s
      if `typeof($[name_s]) !== "undefined"`
        val = `$[name_s]`
        if `typeof(val) === "string"`
          n = `Number($[name_s])`
          val = n unless `isNaN(n)`
          return val
        end
        return ::ObjectiveCObject.new(`$[name_s]`) 
      end
    end
    ::Kernel.raise ::NameError.new("uninitialized constant #{full_const_name}", name)
  end
end

# ObjectiveC access handle
class ::O
  def self.method_missing(name, *args)
    name = name.to_s
    %x{
      if (typeof($[name]) === "undefined") { #{super(name, *args)} }
      if (args.length === 0) {
        return $[name];
      } else {
        return $[name](...args);
      }
    }
  end
end

# ObjectiveC wrapper
class ::ObjectiveCObject
  def initialize(objc_class)
    @native_objective_c = objc_class
  end

  def [](arg)
    res = `self.native_objective_c[arg]`
    return res if `typeof(res) === "string" || typeof(res) === "number"`
    ::ObjectiveCObject.new(res)
  end

  def class
    %x{
      if (self.native_objective_c == $.NSObject || typeof(self.native_objective_c.class) !== "function") {
        return #{::ObjectiveCObject};
      } else {
        let res = self.native_objective_c.class;
        return #{::ObjectiveCObject.new(`res`)}
      }
    }
  end

  def is_a?(type)
    res = super(type)
    return res if res
    %x{
      type = type.native_objective_c;
      if (typeof(self.native_objective_c.isKindOfClass) === "function") {
        return self.native_objective_c.isKindOfCall(type);
      }
      return false;
    }
  end

  def methods
    m = super
    %x{
      if (typeof(self.native_objective_c.class) === "function") {
        let r = Ref("unsigned int");
        let oms = $.class_copyMethodList(self.native_objective_c.class, r);
        var l = r[0];
        let omr, om;
        for (let i = 0; i < l; i++) {
          m.push($.method_getName(oms[i]));
        }
      }
    }
    m
  end

  def respond_to?(m)
    res = super
    return res if res
    m = m.to_s
    res = `(typeof(self.native_objective_c[m]) !== "undefined")`
    res
  end 

  def method_missing(name, *args)
    args = args.map do |arg|
      %x{
        if (typeof(arg.native_objective_c) === "undefined") { return arg; }
        else { return arg.native_objective_c; }
      }
    end
    res = nil;
    %x{
      let r;
      let name_s = name.$to_s();
      if (name_s.endsWith("=")) {
        name_s = name_s.substring(0, name_s.length - 1);
        if (!self.native_objective_c.respondsToSelector($.NSSelectorFromString(name_s)) && typeof(self.native_objective_c[name_s]) === "undefined") { 
          #{super(name, *args)};
        }
        r = self.native_objective_c[name_s] = args[0];
      } else {
        if (!self.native_objective_c.respondsToSelector($.NSSelectorFromString(name_s)) && typeof(self.native_objective_c[name_s]) === "undefined") {
          #{super(name, *args)};
        } else if (args.length === 0) {
          if (name_s === "alloc") {
            r = #{::ObjectiveCObject.new(`self.native_objective_c.alloc`)};
          } else if (name_s === "init") {
            self.native_objective_c = self.native_objective_c.init
            r = self;
          } else {
            // some methods/functions in ObjectiveC space must be called with () some without, so try () first
            try {
              r = self.native_objective_c[name]();
            } catch (e) {
              if (e instanceof TypeError) {
                r = self.native_objective_c[name];
              } else {
                throw e;
              }
            }
          }
        } else {
          r = self.native_objective_c[name](...args);
        }
      }
      if (r === self) {
        res = r;
      } else if (r == $(r)) {
        // got a ObjectiveC object
        res = #{::ObjectiveCObject.new(`r`)}
      } else {
        res = r;
      }
    }
    res
  end

  def to_s
    %x{
      if (typeof(self.native_objective_c.description) === "function") {
        return self.native_objective_c.description.js;
      }
      return "[unknown ObjectiveCObject]";
    }
  end
  alias name to_s
end

class ::ObjC
  class << self
    def bindFunction(name, args)
      # args here is a Array of strings
      `ObjC.bindFunction(name, args)`
    end

    def import(resource)
      `ObjC.import(#{resource})`
    end

    def registerSubclass(class_obj)
      # TODO convert Hash to JS obj
      name = class_obj[:name].to_s
      js_obj = class_obj.to_n
      `ObjC.registerSubclass(js_obj)`
      ::ObjectiveCObject.new(`$[name]`)
    end

    def unwrap(obj)
      `ObjC.unwrap(obj)`
    end

    def wrap(obj)
      `ObjC.wrap(obj)`
    end
  end
end
