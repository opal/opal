# backtick_javascript: true
# use_strict: true
# opal_runtime_mode: true
# helpers: coerce_to_or_nil, coerce_to_or_raise, return_val, Object, platform

module ::Opal
  # Create a new range instance with first and last values, and whether the
  # range excludes the last value.
  def self.range(first, last, exc)
    %x{
      var range         = new Opal.Range();
          range.begin   = first;
          range.end     = last;
          range.excl    = exc;

      return range;
    }
  end

  # top is the main object. It is a `self` in a top level of a Ruby program
  %x{
    Opal.top.$to_s = Opal.top.$inspect = $return_val('main');
    Opal.top.$define_method = top_define_method;

    // Foward calls to define_method on the top object to Object
    function top_define_method() {
      var block = top_define_method.$$p;
      top_define_method.$$p = null;
      return Opal.send($Object, 'define_method', arguments, block)
    };
  }

  # Exit handler, see #create_builder in lib/opal/cli.rb
  def self.run_end_procs_and_exit(system_exit)
    status = system_exit.status

    $__at_exit__ ||= []

    until $__at_exit__.empty?
      block = $__at_exit__.pop
      begin
        block.call
      rescue ::SystemExit => e
        status = e.status
      rescue => e
        # ignore
      end
    end

    `$platform.exit(status)`
  end

  def self.process_check_id(id)
    nid = `$coerce_to_or_nil(id, Opal.String, "to_str")` || `$coerce_to_or_raise(id, Opal.Integer, "to_int")`
    nid = `nid.toString()` if `nid instanceof String`
    nid
  end

  def self.process_spawn_opts_and_execute(args, js_opts)
    arg = args.shift
    coe_arg = `$coerce_to_or_nil(arg, Opal.Hash, "to_hash")`
    if coe_arg
      env = coe_arg.to_h do |k, v|
        if v.nil?
          [k, nil]
        else
          k = `$coerce_to_or_raise(k, Opal.String, "to_str")`
          raise(::ArgumentError, 'invalid env key') if `k.includes("\x00")` || `k.includes("=")`
          v = `$coerce_to_or_raise(v, Opal.String, "to_str")`
          raise(::ArgumentError, 'env value contains null byte') if `v.includes("\x00")`
          [k, v]
        end
      end
      arg = coe_arg = nil
    else
      env = {}
    end

    arg ||= args.shift
    coe_arg = `$coerce_to_or_nil(arg, Opal.Array, "to_ary")`
    if coe_arg
      raise(::ArgumentError, 'array must have 2 elements') unless coe_arg.size == 2
      `js_opts.argv0 = $coerce_to_or_raise(coe_arg[1], Opal.String, "to_str")`
      raise(::ArgumentError, 'cmd contains null byte') if `js_opts.argv0.includes("\x00")`
      cmdname = `$coerce_to_or_raise(coe_arg[0], Opal.String, "to_str")`
      arg = coe_arg = nil
    else
      raise(::ArgumentError, 'no cmd given') if !arg || arg.is_a?(::Hash)
      cmdname = `$coerce_to_or_raise(arg, Opal.String, "to_str")`
    end
    raise Errno::ENOENT if cmdname.empty?

    raise(::ArgumentError, 'no command given') unless cmdname
    raise(::ArgumentError, 'cmd contains null byte') if `cmdname.includes("\x00")`

    opened_files = []
    merge_env = true
    coe_arg = `$coerce_to_or_nil(#{args.last}, Opal.Hash, "to_hash")`
    if coe_arg
      args.pop
      opts = coe_arg

      handle_value = ->(v, i, m) do
        if v.is_a?(::IO)
          `js_opts.stdio[i] = #{v.fileno}`
        elsif v.is_a?(::Integer)
          `js_opts.stdio[i] = #{v}`
        elsif v.is_a?(::String)
          f = File.open(v, m)
          opened_files.push(f)
          `js_opts.stdio[i] = #{f.fileno}`
        elsif v == :close
          `js_opts.stdio[i] = 'ignore'`
        elsif (f = `$coerce_to_or_nil(v, #{::IO}, "to_io")`)
          `js_opts.stdio[i] = #{f.fileno}`
        else
          raise(::ArgumentError, "cannot handle #{v.inspect}")
        end
      end

      opts.each do |k, v|
        case k
        when :chdir
          d = opts[:chdir]
          arg = `$coerce_to_or_nil(d, Opal.String, "to_path")` || `$coerce_to_or_raise(d, Opal.String, "to_str")`
          raise(::ArgumentError, 'chdir contains null byte') if `arg.includes("\x00")`
          `js_opts.cwd = #{arg}.toString()`
        when :close_others
          raise ::NotImplementedError, ':close_others option is not available'
        when :in
          handle_value.call(v, 0, 'r')
        when :out
          handle_value.call(v, 1, 'w')
        when :err
          handle_value.call(v, 2, 'w')
        when :pgroup
          raise(::ArgumentError) if v.is_a?(::Integer) && v < 0
          raise ::NotImplementedError, ':pgroup option is not available'
        when :new_group
          raise ::NotImplementedError, ':new_group option is not available'
        when :umask
          raise ::NotImplementedError, ':umask option is not available'
        when :unsetenv_others
          merge_env = false if v
        else
          if k.to_s.start_with?('rlimit_')
            raise ::NotImplementedError, ':rlimit_* options are not available'
          elsif k.is_a?(::Integer)
            if 0 <= k && k <= 2
              if v.is_a?(::Integer)
                `js_opts.stdio[k] = v`
              else
                handle_value.call(v, k, k == 0 ? 'r' : 'w')
              end
            else
              raise ::NotImplementedError, 'only limited redirection possible for fd 0, 1, 2'
            end
          elsif k.is_a?(::Array)
            k.each { |ky| raise(::ArgumentError, 'invalid stdio key') unless ky == :err || ky == :out }
            handle_value.call(v, 1, 'w')
            `js_opts.stdio[2] = js_opts.stdio[1]`
          else
            raise ::ArgumentError, 'unknown option given'
          end
        end
      end
    end

    args.map! do |ag|
      ag = `$coerce_to_or_raise(ag, Opal.String, "to_str")`
      raise(::ArgumentError, 'arg contains null byte') if `ag.includes("\x00")`
      `ag.$inspect().toString()`
    end

    env = ::ENV.to_h.merge!(env) if merge_env
    js_env = `{}`
    env.each { |k, v| `js_env[k.toString()] = v.toString()` if v }
    `delete js_env["SHELL"]`
    `js_opts.env = js_env`
    `js_opts.shell = true` unless cmdname.match?(/^(\.\/|\/)/)
    if `$platform.alt_sep && !js_opts.shell` &&
       !cmdname.match?("^(\.\\#{`$platform.alt_sep`}|\\#{`$platform.alt_sep`})")
      `js_opts.shell = true`
    end

    # without out raises error 'Unsupported xstr part: js_return (RuntimeError)', so we need to set out
    out = `$platform.process_spawn(#{cmdname}.toString(), #{args}, js_opts)`
    [cmdname, out]
  ensure
    opened_files&.each(&:close)
  end
end

::Opal
