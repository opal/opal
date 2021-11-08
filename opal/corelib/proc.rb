# helpers: slice

class Proc < `Function`
  `Opal.prop(self.$$prototype, '$$is_proc', true)`
  `Opal.prop(self.$$prototype, '$$is_lambda', false)`

  def self.new(&block)
    unless block
      ::Kernel.raise ArgumentError, 'tried to create a Proc object without a block'
    end

    block
  end

  def call(*args, &block)
    %x{
      if (block !== nil) {
        self.$$p = block;
      }

      var result, $brk = self.$$brk;

      if ($brk) {
        try {
          if (self.$$is_lambda) {
            result = self.apply(null, args);
          }
          else {
            result = Opal.yieldX(self, args);
          }
        } catch (err) {
          if (err === $brk) {
            return $brk.$v
          }
          else {
            throw err
          }
        }
      }
      else {
        if (self.$$is_lambda) {
          result = self.apply(null, args);
        }
        else {
          result = Opal.yieldX(self, args);
        }
      }

      return result;
    }
  end

  alias [] call
  alias === call
  alias yield call

  def >>(other)
    proc do |*args, &block|
      out = call(*args, &block)
      other.call(out)
    end
  end

  def <<(other)
    proc do |*args, &block|
      out = other.call(*args, &block)
      call(out)
    end
  end

  def to_proc
    self
  end

  def lambda?
    # This method should tell the user if the proc tricks are unavailable,
    # (see Proc#lambda? on ruby docs to find out more).
    `!!self.$$is_lambda`
  end

  def arity
    %x{
      if (self.$$is_curried) {
        return -1;
      } else {
        return self.$$arity;
      }
    }
  end

  def source_location
    `if (self.$$is_curried) { return nil; }`
    nil
  end

  def binding
    `if (self.$$is_curried) { #{::Kernel.raise ArgumentError, "Can't create Binding"} }`

    if defined? ::Binding
      ::Binding.new(nil, [], `self.$$s`, source_location)
    end
  end

  def parameters
    %x{
      if (self.$$is_curried) {
        return #{[[:rest]]};
      } else if (self.$$parameters) {
        if (self.$$is_lambda) {
          return self.$$parameters;
        } else {
          var result = [], i, length;

          for (i = 0, length = self.$$parameters.length; i < length; i++) {
            var parameter = self.$$parameters[i];

            if (parameter[0] === 'req') {
              // required arguments always have name
              parameter = ['opt', parameter[1]];
            }

            result.push(parameter);
          }

          return result;
        }
      } else {
        return [];
      }
    }
  end

  def curry(arity = undefined)
    %x{
      if (arity === undefined) {
        arity = self.length;
      }
      else {
        arity = #{::Opal.coerce_to!(arity, ::Integer, :to_int)};
        if (self.$$is_lambda && arity !== self.length) {
          #{::Kernel.raise ::ArgumentError, "wrong number of arguments (#{`arity`} for #{`self.length`})"}
        }
      }

      function curried () {
        var args = $slice.call(arguments),
            length = args.length,
            result;

        if (length > arity && self.$$is_lambda && !self.$$is_curried) {
          #{::Kernel.raise ArgumentError, "wrong number of arguments (#{`length`} for #{`arity`})"}
        }

        if (length >= arity) {
          return self.$call.apply(self, args);
        }

        result = function () {
          return curried.apply(null,
            args.concat($slice.call(arguments)));
        }
        result.$$is_lambda = self.$$is_lambda;
        result.$$is_curried = true;

        return result;
      };

      curried.$$is_lambda = self.$$is_lambda;
      curried.$$is_curried = true;
      return curried;
    }
  end

  def dup
    %x{
      var original_proc = self.$$original_proc || self,
          proc = function () {
            return original_proc.apply(this, arguments);
          };

      for (var prop in self) {
        if (self.hasOwnProperty(prop)) {
          proc[prop] = self[prop];
        }
      }

      return proc;
    }
  end

  alias clone dup
end
