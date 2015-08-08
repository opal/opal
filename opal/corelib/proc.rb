class Proc
  `def.$$is_proc = true`
  `def.$$is_lambda = false`

  def self.new(&block)
    unless block
      raise ArgumentError, "tried to create a Proc object without a block"
    end

    block
  end

  def call(*args, &block)
    %x{
      if (block !== nil) {
        self.$$p = block;
      }

      var result;

      if (self.$$is_lambda) {
        result = self.apply(null, args);
      }
      else {
        result = Opal.yieldX(self, args);
      }

      if (result === $breaker) {
        return $breaker.$v;
      }

      return result;
    }
  end

  alias [] call

  def to_proc
    self
  end

  def lambda?
    # This method should tell the user if the proc tricks are unavailable,
    # (see Proc#lambda? on ruby docs to find out more).
    `!!self.$$is_lambda`
  end

  # FIXME: this should support the various splats and optional arguments
  def arity
    `if (self.$$is_curried) { return -1; }`
    `self.length`
  end

  def source_location
    `if (self.$$is_curried) { return nil; }`
    nil
  end

  def binding
    `if (self.$$is_curried) { #{raise ArgumentError, "Can't create Binding"} }`
    nil
  end

  def parameters
    `if (self.$$is_curried) { return #{[[:rest]]}; }`
    nil
  end

  def curry(arity = undefined)
    %x{
      if (arity === undefined) {
        arity = self.length;
      }
      else {
        arity = #{Opal.coerce_to!(arity, Integer, :to_int)};
        if (self.$$is_lambda && arity !== self.length) {
          #{raise ArgumentError, "wrong number of arguments (#{`arity`} for #{`self.length`})"}
        }
      }

      function curried () {
        var args = $slice.call(arguments),
            length = args.length;

        if (length > arity && self.$$is_lambda) {
          #{raise ArgumentError, "wrong number of arguments (#{`length`} for #{`arity`})"}
        }

        if (length >= arity) {
          return self.$call.apply(self, args);
        }

        return function () {
          return curried.apply(null,
            args.concat($slice.call(arguments)));
        }
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
