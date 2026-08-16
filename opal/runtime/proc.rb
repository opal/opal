# backtick_javascript: true
# use_strict: true
# opal_runtime_mode: true
# helpers: apply_blockopts, raise

module ::Opal
  %x{
    function call_lambda(block, arg, ret) {
      try {
        block(arg);
      } catch (e) {
        if (e === ret) {
          return ret.$v;
        }
        throw e;
      }
    }
  }

  def self.lambda(block, blockopts)
    %x{
      block.$$is_lambda = true;

      $apply_blockopts(block, blockopts);

      return block;
    }
  end

  # Arity count error dispatcher for blocks
  #
  # @param actual [Fixnum] number of arguments given to block
  # @param expected [Fixnum] expected number of arguments
  # @param context [Object] context of the block definition
  # @raise [ArgumentError]
  def self.block_ac(actual, expected, context)
    %x{
      var inspect = "`block in " + context + "'";

      $raise(Opal.ArgumentError, inspect + ': wrong number of arguments (given ' + actual + ', expected ' + expected + ')');
    }
  end

  # Number of parameters a block declares, used to decide whether a single
  # yielded array should be auto-splatted.
  #
  # NOTE: `block.length` is the accurate count, but a JS minifier may drop
  # trailing unused parameters (as generated for a bare splat, `{ |x, *| }`),
  # making it under-report. `$$arity` survives minification, so it is used as a
  # lower bound. It cannot replace `length` outright: for a block taking only
  # optional args, `{ |a=1, b=2| }` has an arity of -1 but declares 2 params.
  def self.block_length(block)
    %x{
      var length = block.length;

      if (typeof block.$$arity === 'number') {
        var from_arity = Math.abs(block.$$arity);
        if (from_arity > length) length = from_arity;
      }

      return length
    }
  end

  # handles yield calls for 1 yielded arg
  def self.yield1(block, arg)
    %x{
      if (typeof(block) !== "function") {
        $raise(Opal.LocalJumpError, "no block given");
      }

      var has_mlhs = block.$$has_top_level_mlhs_arg,
          has_trailing_comma = block.$$has_trailing_comma_in_args,
          is_returning_lambda = block.$$is_lambda && block.$$ret,
          // NOTE: $$arity is authoritative: a JS minifier is free to drop trailing
          // unused parameters, which would silently shrink block.length.
          length = Opal.block_length(block);

      if (length > 1 || ((has_mlhs || has_trailing_comma) && length === 1)) {
        arg = Opal.to_ary(arg);
      }

      if ((length > 1 || (has_trailing_comma && length === 1)) && arg.$$is_array) {
        if (is_returning_lambda) {
          return call_lambda(block.apply.bind(block, null), arg, block.$$ret);
        }
        return block.apply(null, arg);
      }
      else {
        if (is_returning_lambda) {
          return call_lambda(block, arg, block.$$ret);
        }
        return block(arg);
      }
    }
  end

  # handles yield for > 1 yielded arg
  def self.yieldX(block, args)
    %x{
      if (typeof(block) !== "function") {
        $raise(Opal.LocalJumpError, "no block given");
      }

      if (Opal.block_length(block) > 1 && args.length === 1) {
        if (args[0].$$is_array) {
          args = args[0];
        }
      }

      if (block.$$is_lambda && block.$$ret) {
        return call_lambda(block.apply.bind(block, null), args, block.$$ret);
      }
      return block.apply(null, args);
    }
  end
end

::Opal
