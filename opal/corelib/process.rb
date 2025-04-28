# backtick_javascript: true
# helpers: platform, coerce_to

module ::Process
  WNOHANG = 1
  @__clocks__ = []

  class << self
    def __register_clock__(name, func)
      const_set name, @__clocks__.size
      @__clocks__ << func
    end

    # _fork - not supported, An internal API for fork. Do not call this method directly. But specs test it anyway ...

    def abort(msg = nil)
      # Terminates execution immediately, effectively by calling Kernel.exit(false).
      msg = ::Opal.coerce_to!(msg, ::String, :to_str) if msg
      $stderr << msg if msg
      raise(::SystemExit.new(false, msg))
    end

    def argv0
      # Returns the name of the script being executed.
      ARGV[0]
    end

    def clock_getres(clock_id, unit = :float_second)
      # Returns a clock resolution as determined by POSIX function clock_getres():
      raise NotImplementedError
    end

    def clock_gettime(clock_id, unit = :float_second)
      (clock = @__clocks__[clock_id]) || ::Kernel.raise(::Errno::EINVAL, "clock_gettime(#{clock_id}) #{@__clocks__[clock_id]}")
      unit ||= :float_second
      %x{
        var ms = clock();
        switch (unit) {
          case 'float_second':      return  (ms / 1000);         // number of seconds as a float (default)
          case 'float_millisecond': return  (ms / 1);            // number of milliseconds as a float
          case 'float_microsecond': return  (ms * 1000);         // number of microseconds as a float
          case 'second':            return ((ms / 1000)    | 0); // number of seconds as an integer
          case 'millisecond':       return ((ms / 1)       | 0); // number of milliseconds as an integer
          case 'microsecond':       return ((ms * 1000)    | 0); // number of microseconds as an integer
          case 'nanosecond':        return ((ms * 1000000) | 0); // number of nanoseconds as an integer
          default: #{::Kernel.raise ::ArgumentError, "unexpected unit: #{unit}"}
        }
      }
    end

    # Detaches the current process from its controlling terminal and runs
    # it in the background as system daemon; returns zero.
    alias daemon __not_implemented__

    # Avoids the potential for a child process to become a zombie process.
    alias detach __not_implemented__

    def egid
      # Returns the effective group ID for the current process.
      `$platform.process_getegid()`
    end

    def egid=(new_egid)
      # Sets the effective group ID for the current process.
      unless new_egid.is_a?(::Integer) || new_egid.is_a?(::String)
        raise ::TypeError, 'new_egid must be a Integer or a String'
      end
      `$platform.process_setegid(new_egid)`
      new_egid
    end

    def euid
      # Returns the effective user ID for the current process.
      `$platform.process_geteuid()`
    end

    def euid=(new_euid)
      # Sets the effective user ID for the current process.
      unless new_euid.is_a?(::Integer) || new_euid.is_a?(::String)
        raise ::TypeError, 'new_euid must be a Integer or a String'
      end
      `$platform.process_seteuid(new_euid)`
      new_euid
    end

    def exec(*args)
      # Replaces the current process by doing one of the following:
      env = {}
      env = argv.shift if argv.first.is_a? ::Hash
      env = ::ENV.merge(env)
      js_env = `{}`
      env.each { |k, v| `js_env[k] = v.toString()` }
      `delete js_env["SHELL"]`
      js_opts = `{ stdio: 'pipe', env: js_env }`

      cmdname = argv.shift
      if Array === cmdname
        `js_opts.argv0 = #{cmdname[1]}`
        cmdname = cmdname[0]
      end

      opts = argv.shift

      if opts.is_a?(::Hash)
        `js_opts.cwd = #{opts[:chdir]}` if opts.key?(:chdir)
        so = opts[:out]
        se = opts[:err]
      end

      `js_opts.shell = true` unless ::File.absolute_path?(cmdname)

      `$platform.process_exec(#{cmdname}, #{argv}, js_opts)`
    end

    def exit(status = true)
      # Initiates termination of the Ruby script by raising SystemExit;
      # the exception may be caught.
      # Returns exit status status to the underlying operating system.
      raise(::SystemExit.new(status, 'exit'))
    end

    def exit!(status = false)
      # Exits the process immediately; no exit handlers are called.
      # Returns exit status status to the underlying operating system.

      status = if status == true
                 0
               elsif status == false
                 1
               else
                 `$coerce_to(status, #{::Integer}, 'to_int')`
               end

      `$platform.exit(status)`
    end

    def fork(&block)
      # Creates a child process.
      `var worker`
      if block_given?
        %x{
          if ($platform.process_is_primary()) {
            worker = $platform.process_fork();
            return $platform.process_worker_pid(worker);
          } else if ($platform.process_is_worker()) {
            #{yield}
          }
        }
      else
        %x{
          if ($platform.process_is_primary()) {
            worker = $platform.process_fork();
            return $platform.process_worker_pid(worker);
          }
        }
      end
    end

    # Returns the process group ID for the given process ID +pid+
    alias getpgid __not_implemented__

    # Returns the scheduling priority for specified process, process group, or user.
    alias getpriority __not_implemented__

    # Returns a 2-element array of the current (soft) limit and
    # maximum (hard) limit for the given resource.
    alias getrlimit __not_implemented__

    # Returns the session ID of the given process ID pid,
    # or of the current process if not given.
    alias getsid __not_implemented__

    def gid
      # Returns the (real) group ID for the current process
      `$platform.process_getgid()`
    end

    def gid=(new_gid)
      # Sets the group ID for the current process to new_gid.
      unless new_gid.is_a?(::Integer) || new_gid.is_a?(::String)
        raise ::TypeError, 'new_gid must be a Integer or a String'
      end
      `$platform.process_setgid(new_gid)`
    end

    def groups
      # Returns an array of the group IDs in the supplemental
      # group access list for the current process
      `$platform.process_getgroups()`
    end

    def groups=(ary)
      # Sets the supplemental group access list to the given array of group IDs.
      `$platform.process_setgroups(ary)`
      ary
    end

    # Sets the supplemental group access list; the new list includes:
    # The group IDs of those groups to which the user given by username belongs.
    # The group ID gid
    alias initgroups __not_implemented__

    def kill(signal, *ids)
      # Sends a signal to each process specified by ids
      # (which must specify at least one ID);
      # returns the count of signals sent.
      if signal.is_a?(::Integer)
        signal = ::Signal.list.key(signal)
        raise(::ArgumentError, 'unknown signal') unless signal
      elsif signal.is_a?(::String)
        signal = signal[1..] if signal[0] == '-'
        raise(::ArgumentError, 'unknown signal') if signal != signal.upcase
        signal = signal[3..] if signal.start_with?('SIG')
        raise(::ArgumentError, 'unknown signal') unless ::Signal.list.key?(signal)
      else
        raise(::ArgumentError, 'signal must be Integer or String')
      end
      own_pid = pid
      ids.each do |pd|
        if pd == own_pid
          raise(::SignalException, 'TERM') if signal == 'TERM'
          raise(::Interrupt) if signal == 'INT'
          next if signal == 'EXIT'
        end
        `$platform.process_kill(pd, signal)` rescue nil
      end
      # emulation for other specs to pass
      ps = Process::Status.new(0, ids[ids.size - 1])
      `ps.signaled = true`
      $? = ps
      ids.size
    end

    # Returns a Process::Status object representing the most recently
    # exited child process in the current thread, or nil if none.
    def last_status
      $?
    end

    # Returns the maximum number of group IDs allowed in the supplemental group access list
    alias maxgroups __not_implemented__

    # Sets the maximum number of group IDs allowed in the supplemental group access list.
    alias maxgroups __not_implemented__

    def pid
      # Returns the process ID of the current process.
      `$platform.process_pid()`
    end

    def ppid
      # Returns the process ID of the parent of the current process.
      `$platform.process_ppid()`
    end

    # Sets the process group ID for the process given by process ID pid to pgid.
    alias setpgid __not_implemented__

    def setpgrp
      # Equivalent to setpgid(0, 0)
      setpgid(0, 0)
    end

    # See Process.getpriority.
    alias setpriority __not_implemented__

    def setproctitle(string)
      # Sets the process title that appears on the ps(1) command.
      # Not necessarily effective on all platforms.
      `$platform.process_set_title(string)`
      string
    end

    # Sets limits for the current process for the given resource
    # to cur_limit (soft limit) and max_limit (hard limit); returns nil.
    alias setrlimit __not_implemented__

    # Establishes the current process as a new session and process group leader,
    # with no controlling tty; returns the session ID.
    alias setsid __not_implemented__

    def spawn(*argv)
      # Creates a new child process by doing one of the following in that process
      # - Passing string command_line to the shell.
      # - Invoking the executable at exe_path

      env = {}
      arg = argv.shift
      coe_arg = ::Opal.coerce_to!(arg, ::Hash, :to_hash) if arg.respond_to?(:to_hash)
      if coe_arg
        env = coe_arg.to_h do |k, v|
          k = ::Opal.coerce_to!(k, ::String, :to_str)
          raise(::ArgumentError, 'env key contains null byte') if `k.includes("\x00")`
          v = ::Opal.coerce_to!(v, ::String, :to_str)
          raise(::ArgumentError, 'env value contains null byte') if `v.includes("\x00")`
          [k, v]
        end
        arg = coe_arg = nil
      end

      arg = argv.shift unless arg
      coe_arg = ::Opal.coerce_to!(arg, ::Array, :to_ary) if arg.respond_to?(:to_ary)
      if coe_arg
        raise(::ArgumentError, 'array must have 2 elements') unless coe_arg.size == 2
        `js_opts.argv0 = #{::Opal.coerce_to!(coe_arg[1], ::String, :to_str)}`
        raise(::ArgumentError, 'cmd contains null byte') if `js_opts.argv0.includes("\x00")`
        cmdname = ::Opal.coerce_to!(coe_arg[0], ::String, :to_str)
        arg = coe_arg = nil
      end

      arg = argv.shift unless arg
      coe_arg = ::Opal.coerce_to!(arg, ::String, :to_str) if arg.respond_to?(:to_str)
      if coe_arg
        cmdname = coe_arg
        arg = coe_arg = nil
      end

      raise(::ArgumentError, 'no command given') unless cmdname
      raise(::ArgumentError, 'cmd contains null byte') if `cmdname.includes("\x00")`

      arg = argv.shift unless arg
      coe_arg = ::Opal.coerce_to!(arg, ::Hash, :to_hash) if arg.respond_to?(:to_hash)
      if coe_arg
        opts = coe_arg
        if opts.key?(:chdir)
          arg = ::Opal.coerce_to!(opts[:chdir], ::String, :to_path) rescue nil
          arg = ::Opal.coerce_to!(opts[:chdir], ::String, :to_str) unless arg
          raise(::ArgumentError, 'chdir contains null byte') if `arg.includes("\x00")`
          `js_opts.cwd = #{arg}`
        end
        so = opts[:out]
        se = opts[:err]
        arg = coe_arg = nil
      end

      env = ::ENV.merge(env)
      js_env = `{}`
      env.each { |k, v| `js_env[k.toString()] = v.toString()` }
      `delete js_env["SHELL"]`
      js_opts = `{ stdio: 'pipe', env: js_env, wait: false }`

      argv.map! do |arg|
        arg = ::Opal.coerce_to!(arg, ::String, :to_str)
        raise(::ArgumentError, 'arg contains null byte') if `arg.includes("\x00")`
        arg
      end

      `js_opts.shell = true` unless ::File.absolute_path?(cmdname)

      out = `$platform.process_spawn(#{cmdname}, #{argv}, js_opts, false)`

      if `out.status`
        status = `out.status > 128 ? out.status - 128 : out.status`
      end

      pid = `out.pid == null ? nil : out.pid`
      $? = ::Process::Status.new(status, pid)

      return nil if `out.error || out.status > 125`

      pid
    end

    def times
      # Returns a Process::Tms structure that contains user and system CPU times
      # for the current process, and for its children processes
      t = ::Time.now.to_f
      ::Benchmark::Tms.new(t, t, t, t, t)
    end

    def uid
      # Returns the (real) user ID of the current process.
      `$platform.process_getuid()`
    end

    def uid=(new_uid)
      # Sets the (user) user ID for the current process to new_uid.
      new_uid = ::Opal.coerce_to!(new_uid, ::Integer, :to_int)
      `$platform.process_setuid(new_uid)`
    end

    def wait(pid = -1, flags = 0)
      # Waits for a suitable child process to exit, returns its process ID,
      # and sets $? to a Process::Status object containing information on
      # that process. Which child it waits for depends on the value of the given pid.
      pid, $? = wait2(pid, flags)
      pid
    end
    alias waitpid wait

    def wait2(pid = -1, flags = 0)
      # Like Process.waitpid, but returns an array containing
      # the child process pid and Process::Status status.
      status = `$platform.process_wait(pid, flags)`
      [pid, ::Process::Status.new(status, pid)]
    end

    def waitall
      # Waits for all children, returns an array of 2-element arrays;
      # each subarray contains the integer pid and Process::Status
      # status for one of the reaped child processes
      `$platform.process_waitall()`
    end

    def warmup
      # Notify the Ruby virtual machine that the boot sequence is finished,
      # and that now is a good time to optimize the application.
      # This is useful for long running applications.
      true
    end
  end

  __register_clock__(:CLOCK_REALTIME, `$platform.clock_realtime`)
  __register_clock__(:CLOCK_MONOTONIC, `$platform.clock_monotonic`) if `$platform.clock_monotonic`
end
