# helpers: respond_to, falsy, truthy

module ObjectSpace
  module_function

  %x{
    var callers = {}, registry, add_caller, delete_callers;
    if (typeof FinalizationRegistry === "function") {
      registry = new FinalizationRegistry(function(id) {
        if (typeof callers[id] !== "undefined") {
          for (var i = 0; i < callers[id].length; i++) {
            #{`callers[id][i]`.call(`id`)};
          }
          delete callers[id];
        }
      });
      add_caller = function(id, value) {
        callers[id] = callers[id] || [];
        callers[id].push(value);
      }
      delete_callers = function(id) {
        delete callers[id];
      }
    }
    else {
      // A weak polyfill for FinalizationRegistry
      registry = {
        register: function(){},
        unregister: function(){}
      };
      add_caller = function(){};
      delete_callers = function(){};
    }
  }

  def define_finalizer(obj, aproc = undefined, &block)
    %x{
      if ($truthy(block)) aproc = block;
      if ($falsy(aproc)) aproc = #{proc};
      if (!$respond_to(aproc, '$call')) {
        #{::Kernel.raise ::ArgumentError, "Wrong type argument #{aproc.class} (should be callable)"};
      }
      var id = #{obj.__id__};
      add_caller(id, aproc);
      try {
        registry.register(obj, id, obj);
      }
      catch (e) {
        delete_callers(id);
        #{::Kernel.raise ::ArgumentError, "cannot define finalizer for #{obj.class}"};
      }
      return [0, aproc];
    }
  end

  def undefine_finalizer(obj)
    %{
      var id = #{obj.__id__};
      registry.unregister(obj);
      delete_callers(id);
      return obj;
    }
  end

  class WeakMap
    include Enumerable

    def initialize
      @weak_map = `new WeakMap()`
      @primitive_map = {}
    end

    def [](p1)
      %x{
        if (typeof p1 !== "function" && typeof p1 !== "object") return #{@primitive_map[p1]};
        return #{@weak_map}.get(p1);
      }
    end

    def []=(p1, p2)
      %x{
        if (typeof p1 !== "function" && typeof p1 !== "object") return #{@primitive_map[p1] = p2};
        return #{@weak_map}.set(p1, p2);
      }
    end

    def include?(p1)
      %x{
        if (typeof p1 !== "function" && typeof p1 !== "object") return #{@primitive_map.key? p1};
        return #{@weak_map}.has(p1);
      }
    end
    alias member? include?
    alias key? include?

    %i[each each_key each_value each_pair keys values size length].each do |i|
      define_method i do |*|
        ::Kernel.raise ::NotImplementedError, "##{i} can't be implemented on top of JS interfaces"
      end
    end
  end
end
