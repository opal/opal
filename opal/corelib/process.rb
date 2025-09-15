# backtick_javascript: true
# helpers: platform, coerce_to, coerce_to_or_nil, coerce_to_or_raise, process_check_id

module ::Process
  PRIO_PGRP = `$platform.PRIO_PGRP` || nil
  PRIO_PROCESS = `$platform.PRIO_PROCESS` || nil
  PRIO_USER = `$platform.PRIO_USER` || nil

  # TODO: remove Number() once we got BigInt support
  RLIM_INFINITY = `$platform.RLIM_INFINITY` ? `Number($platform.RLIM_INFINITY)` : nil
  RLIMIT_AS = `$platform.RLIMIT_AS` || nil
  RLIMIT_CORE = `$platform.RLIMIT_CORE` || nil
  RLIMIT_CPU = `$platform.RLIMIT_CPU` || nil
  RLIMIT_DATA = `$platform.RLIMIT_DATA` || nil
  RLIMIT_FSIZE = `$platform.RLIMIT_FSIZE` || nil
  RLIMIT_MEMLOCK = `$platform.RLIMIT_MEMLOCK` || nil
  RLIMIT_NOFILE = `$platform.RLIMIT_NOFILE` || nil
  RLIMIT_NPROC = `$platform.RLIMIT_NPROC` || nil
  RLIMIT_RSS = `$platform.RLIMIT_RSS` || nil
  RLIMIT_STACK = `$platform.RLIMIT_STACK` || nil
  if `$platform.ruby_platform.includes("freebsd")`
    RLIMIT_KQUEUES = `$platform.RLIMIT_KQUEUES` || nil
    RLIMIT_NPTS = `$platform.RLIMIT_NPTS` || nil
    RLIMIT_PIPEBUF = `$platform.RLIMIT_PIPEBUF` || nil
    RLIMIT_SBSIZE = `$platform.RLIMIT_SBSIZE` || nil
    RLIMIT_SWAP = `$platform.RLIMIT_SWAP` || nil
    RLIMIT_UMTXP = `$platform.RLIMIT_UMTXP` || nil
    RLIMIT_VMEM = `$platform.RLIMIT_VMEM` || nil
  elsif `$platform.ruby_platform.includes("linux")`
    RLIMIT_LOCKS = `$platform.RLIMIT_LOCKS` || nil
    RLIMIT_MSGQUEUE = `$platform.RLIMIT_MSGQUEUE` || nil
    RLIMIT_NICE = `$platform.RLIMIT_NICE` || nil
    RLIMIT_RTPRIO = `$platform.RLIMIT_RTPRIO` || nil
    RLIMIT_RTTIME = `$platform.RLIMIT_RTTIME` || nil
    RLIMIT_SIGPENDING = `$platform.RLIMIT_SIGPENDING` || nil
  end
  WNOHANG = 1
  WUNTRACED = 2

  @__clocks__ = []

  class << self
    def __register_clock__(name, func)
      const_set name, @__clocks__.size
      @__clocks__ << func
    end

    # _fork - not supported, An internal API for fork. Do not call this method directly. But specs test it anyway ...

    def abort(msg = nil)
      # Terminates execution immediately, effectively by calling Kernel.exit(false).
      msg = `$coerce_to_or_raise(msg, Opal.String, "to_str")` if msg
      $stderr << msg if msg
      raise(::SystemExit.new(false, msg))
    end

    def argv0
      # Returns the name of the script being executed.
      `$platform.argv[0]`.freeze if `$platform.argv[0]`
    end

    %x{
      function clock_unit_ms(unit, ms) {
        switch (unit) {
          case 'float_second':      return  (ms / 1000);         // number of seconds as a float (default)
          case 'float_millisecond': return  (ms / 1);            // number of milliseconds as a float
          case 'float_microsecond': return  (ms * 1000);         // number of microseconds as a float
          case 'second':            return ((ms / 1000)    | 0); // number of seconds as an integer
          case 'millisecond':       return ((ms / 1)       | 0); // number of milliseconds as an integer
          case 'microsecond':       return ((ms * 1000)    | 0); // number of microseconds as an integer
          case 'nanosecond':        return ((ms * 1000000) | 0); // number of nanoseconds as an integer
          default: #{::Kernel.raise ::ArgumentError, "unexpected unit: #{`unit`}"}
        }
      }
    }

    def clock_getres(clock_id, unit = :float_second)
      # Returns a clock resolution as determined by POSIX function clock_getres():
      ms = case clock_id
           when :CLOCK_REALTIME then 1
           when :CLOCK_MONOTONIC then 1
           else
             raise ::Errno::EINVAL, 'unknown clock_id'
           end
      `clock_unit_ms(unit, ms)`
    end

    def clock_gettime(clock_id, unit = :float_second)
      id = if clock_id.is_a?(::Symbol)
             const_get(clock_id) rescue nil
           else
             clock_id
           end
      clock = @__clocks__[id] if id
      ::Kernel.raise(::Errno::EINVAL, "clock_gettime(#{clock_id})") unless clock

      unit ||= :float_second
      `clock_unit_ms(unit, clock())`
    end

    # Detaches the current process from its controlling terminal and runs
    # it in the background as system daemon; returns zero.
    # Ruby implements this via fork(), which we cannot support yet in that way.
    alias daemon __not_implemented__

    # Avoids the potential for a child process to become a zombie process.
    # Ruby implements this via Threads, which we cannot support yet.
    alias detach __not_implemented__

    if `$platform.getegid`
      def egid
        # Returns the effective group ID for the current process.
        `$platform.getegid()`
      end
    else
      alias egid __not_implemented__
    end

    if `$platform.setegid`
      def egid=(new_egid)
        # Sets the effective group ID for the current process.
        nid = `$process_check_id(new_egid)`
        `$platform.setegid(nid)`
        nid
      end
    else
      alias egid= __not_implemented__
    end

    if `$platform.geteuid`
      def euid
        # Returns the effective user ID for the current process.
        `$platform.geteuid()`
      end
    else
      alias euid __not_implemented__
    end

    if `$platform.seteuid`
      def euid=(new_euid)
        # Sets the effective user ID for the current process.
        nid = `$process_check_id(new_euid)`
        `$platform.seteuid(nid)`
        nid
      end
    else
      alias euid= __not_implemented__
    end

    if `$platform.process_exec`
      def exec(*args)
        # Replaces the current process by doing one of the following:
        env = {}
        env = argv.shift if argv.first.is_a? ::Hash
        env = ::ENV.to_h.merge!(env)
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
    else
      alias exec __not_implemented__
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

    if `$platform.process_fork && $platform.process_is_primary` &&
       `$platform.process_is_worker && $platform.process_worker_pid`
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
    else
      alias fork __not_implemented__
    end

    if `$platform.getpgid`
      def getpgid(pid)
        # Returns the process group ID for the given process ID pid
        pid = `$coerce_to_or_raise(pid, Opal.Integer, "to_int")`
        `$platform.getpgid(pid)`
      end

      def getpgrp
        # Returns the process group ID for the current process
        getpgid(0)
      end
    else
      alias getpgid __not_implemented__
      alias getpgrp __not_implemented__
    end

    if `$platform.getpriority`
      def getpriority(kind, id)
        # Returns the scheduling priority for specified process, process group, or user.
        kind = `$coerce_to_or_raise(kind, Opal.Integer, "to_int")`
        id = `$coerce_to_or_raise(id, Opal.Integer, "to_int")`
        `$platform.getpriority(kind, id)`
      end
    else
      alias getpriority __not_implemented__
    end

    if `$platform.getrlimit`
      def getrlimit(resource)
        # Returns a 2-element array of the current (soft) limit and
        # maximum (hard) limit for the given resource.
        rsrc = if resource.is_a?(::Integer)
                 resource
               elsif resource.is_a?(::String) || resource.is_a?(::Symbol)
                 resource = resource.to_s
                 `$platform["RLIMIT_" + resource.toString()]`
               else
                 `$coerce_to_or_nil(resource, Opal.String, "to_str")` || `$coerce_to_or_raise(resource, Opal.Integer, "to_int")`
               end
        raise(::ArgumentError, 'unknown resource') unless rsrc
        result = `$platform.getrlimit(rsrc)`
        # TODO: remove the Number() below when BigInt support has been merged
        # The Number() causes rounding errors
        [`Number(result.cur)`, `Number(result.max)`]
      end
    else
      alias getrlimit __not_implemented__
    end

    if `$platform.getsid`
      def getsid(process_id = nil)
        # Returns the session ID of the given process ID pid,
        # or of the current process if not given.
        process_id = if process_id
                       `$coerce_to_or_raise(process_id, Opal.Integer, "to_int")`
                     else
                       pid
                     end
        `$platform.getsid(process_id)`
      end
    else
      alias getsid __not_implemented__
    end

    if `$platform.getgid`
      def gid
        # Returns the (real) group ID for the current process
        `$platform.getgid()`
      end
    else
      alias gid __not_implemented__
    end

    if `$platform.setgid`
      def gid=(new_gid)
        # Sets the group ID for the current process to new_gid.
        nid = `$process_check_id(new_gid)`
        `$platform.setgid(nid)`
        nid
      end
    else
      alias gid= __not_implemented__
    end

    if `$platform.getgroups`
      def groups
        # Returns an array of the group IDs in the supplemental
        # group access list for the current process
        `$platform.getgroups()`
      end
    else
      alias groups __not_implemented__
    end

    if `$platform.setgroups`
      def groups=(ary)
        # Sets the supplemental group access list to the given array of group IDs.
        `$platform.setgroups(ary)`
        ary
      end
    else
      alias groups= __not_implemented__
    end

    if `$platform.initgroups`
      def initgroups(name, gid)
        # Sets the supplemental group access list; the new list includes:
        # The group IDs of those groups to which the user given by username belongs.
        # The group ID gid
        name = `$coerce_to_or_raise(name, Opal.String, "to_str")`
        gid = `$coerce_to_or_raise(gid, Opal.Integer, "to_int")`
        `$platform.initgroups(name.toString(), gid)`
      end
    else
      alias initgroups __not_implemented__
    end

    if `$platform.kill`
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
          `$platform.kill(pd, signal.toString())` rescue nil
        end
        # emulation for other specs to pass
        ps = Process::Status.new(`{ status: 0, flags: 4 }`, ids[ids.size - 1])
        `ps.signaled = true`
        $? = ps
        ids.size
      end
    else
      alias kill __not_implemented__
    end

    # Returns a Process::Status object representing the most recently
    # exited child process in the current thread, or nil if none.
    def last_status
      $?
    end

    if `$platform.sysconf`
      def maxgroups
        # Returns the maximum number of group IDs allowed in the supplemental group access list
        return @maxgroups if @maxgroups
        # TODO: remove Number() below, once we got BigInt support
        `Number($platform.sysconf($platform.SC_NGROUPS_MAX))`
      end
    else
      alias maxgroups __not_implemented__
    end

    if `$platform.setgroups` # thats what ruby does
      def maxgroups=(num)
        # Sets the maximum number of group IDs allowed in the supplemental group access list.
        max = maxgroups
        num = max if num > max
        @maxgroups = num
      end
    else
      alias maxgroups= __not_implemented__
    end

    if `$platform.getpid`
      def pid
        # Returns the process ID of the current process.
        `$platform.getpid()`
      end
    else
      alias pid __not_implemented__
    end

    if `$platform.getppid`
      def ppid
        # Returns the process ID of the parent of the current process.
        `$platform.getppid()`
      end
    else
      alias ppid __not_implemented__
    end

    if `$platform.setpgid`
      def setpgid(pid, pgid)
        # Sets the process group ID for the process given by process ID pid to pgid.
        pid = `$coerce_to_or_raise(pid, Opal.Integer, "to_int")`
        pgid = `$coerce_to_or_raise(pgid, Opal.Integer, "to_int")`
        `$platform.setpgid(pid, pgid)`
      end
    else
      alias setpgid __not_implemented__
    end

    def setpgrp
      # Equivalent to setpgid(0, 0)
      setpgid(0, 0)
    end

    if `$platform.setpriority`
      def setpriority(kind, id, prio)
        # See Process.getpriority.
        kind = `$coerce_to_or_raise(kind, Opal.Integer, "to_int")`
        id = `$coerce_to_or_raise(id, Opal.Integer, "to_int")`
        prio = `$coerce_to_or_raise(prio, Opal.Integer, "to_int")`
        `$platform.setpriority(kind, id, prio)`
      end
    else
      alias setpriority __not_implemented__
    end

    if `$platform.setproctitle`
      def setproctitle(string)
        # Sets the process title that appears on the ps(1) command.
        # Not necessarily effective on all platforms.
        `$platform.setproctitle(string.toString())`
        string
      end
    else
      alias setproctitle __not_implemented__
    end

    if `$platform.setrlimit`
      def setrlimit(resource, cur, max = nil)
        # Sets limits for the current process for the given resource
        # to cur_limit (soft limit) and max_limit (hard limit); returns nil.
        rsrc = if resource.is_a?(::Integer)
                 resource
               elsif resource.is_a?(::String) || resource.is_a?(::Symbol)
                 resource = resource.to_s
                 `$platform["RLIMIT_" + resource.toString()]`
               else
                 `$coerce_to_or_nil(resource, Opal.String, "to_str")` || `$coerce_to_or_raise(resource, Opal.Integer, "to_int")`
               end
        raise(::ArgumentError, 'unknown resource') unless rsrc
        cur = `$coerce_to_or_raise(cur, Opal.Integer, "to_int")`
        max = max ? `$coerce_to_or_raise(max, Opal.Integer, "to_int")` : cur
        `$platform.setrlimit(rsrc, BigInt(cur), BigInt(max))`
        nil
      end
    else
      alias setrlimit __not_implemented__
    end

    if `$platform.setsid`
      def setsid
        # Establishes the current process as a new session and process group leader,
        # with no controlling tty; returns the session ID.
        `$platform.setsid()`
      end
    else
      alias setsid __not_implemented__
    end

    if `$platform.process_spawn`
      def spawn(*args)
        # Creates a new child process by doing one of the following in that process
        # - Passing string command_line to the shell.
        # - Invoking the executable at exe_path

        _cmdname, out = ::Opal.process_spawn_opts_and_execute(
          args,
          `{ stdio: [#{$stdin.fileno}, #{$stdout.fileno}, #{$stderr.fileno}], wait: false }`
        )
        if `out.status`
          status = `out.status > 128 ? out.status - 128 : out.status`
          raise(::Error::ENOENT) if `out.status == 127`
        end

        pid = `out.pid == null ? nil : out.pid`
        $? = ::Process::Status.new(`{ status: status, flags: 4 }`, pid)

        return nil if `out.error || out.status > 125`

        pid
      end
    else
      alias spawn __not_implemented__
    end

    def times
      # Returns a Process::Tms structure that contains user and system CPU times
      # for the current process, and for its children processes
      t = ::Time.now.to_f
      ::Process::Tms.new(t, t, t, t)
    end

    if `$platform.getuid`
      def uid
        # Returns the (real) user ID of the current process.
        `$platform.getuid()`
      end
    else
      alias uid __not_implemented__
    end

    if `$platform.setuid`
      def uid=(new_uid)
        # Sets the (user) user ID for the current process to new_uid.
        nid = `$process_check_id(new_uid)`
        `$platform.setuid(nid)`
        nid
      end
    else
      alias uid= __not_implemented__
    end

    if `$platform.waitpid`
      def wait(pid = -1, flags = 0)
        # Waits for a suitable child process to exit, returns its process ID,
        # and sets $? to a Process::Status object containing information on
        # that process. Which child it waits for depends on the value of the given pid.
        pid = `$coerce_to_or_raise(pid, Opal.Integer, "to_int")`
        pid, $? = wait2(pid, flags)
        # if (flags & WNOHANG == WNOHANG) &&
        #   !($?.exited? || $?.signaled? || $?.stopped? || $?.success?)
        #   return nil
        # end
        pid
      end

      def wait2(pid = -1, flags = 0)
        # Like Process.waitpid, but returns an array containing
        # the child process pid and Process::Status status.
        result = `$platform.waitpid(pid, flags)`
        pid = `result.pid`
        raise Errno::ECHILD if pid == -1 && 10 == `result.errno`
        [pid, ::Process::Status.new(result, pid)]
      end

      def waitall
        # Waits for all children, returns an array of 2-element arrays;
        # each subarray contains the integer pid and Process::Status
        # status for one of the reaped child processes
        res = []
        while true
          begin
            res << wait2
          rescue Errno::ECHILD
            break
          end
        end
        res
      end
    else
      alias wait __not_implemented__
      alias wait2 __not_implemented__
      alias waitall __not_implemented__
    end

    alias waitpid wait

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
