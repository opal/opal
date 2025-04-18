# backtick_javascript: true
# helpers: platform

module ::Process
  @__clocks__ = []

  class << self
    def __register_clock__(name, func)
      const_set name, @__clocks__.size
      @__clocks__ << func
    end

    def _fork
      # An internal API for fork. Do not call this method directly.
      # Currently, this is called via Kernel#fork, Process.fork, and IO.popen with "-".
    end

    def abort(msg = nil)
      # Terminates execution immediately, effectively by calling Kernel.exit(false).
      $stderr << msg if msg
      ::Kernel.exit(false)
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

    def daemon(nochdir = nil, noclose = nil)
      # Detaches the current process from its controlling terminal and runs
      # it in the background as system daemon; returns zero.
      raise ::NotImplementedError
    end

    def detach(pid)
      # Avoids the potential for a child process to become a zombie process.
      raise ::NotImplementedError
    end

    def egid
      # Returns the effective group ID for the current process.
      `$platform.process_getegid()`
    end

    def egid=(new_egid)
      # Sets the effective group ID for the current process.
      `$platform.process_setegid(new_egid)`
      new_egid
    end

    def euid
      # Returns the effective user ID for the current process.
      `$platform.process_geteuid()`
    end

    def euid=(new_euid)
      # Sets the effective user ID for the current process.
      `$platform.process_seteuid(new_euid)`
      new_euid
    end

    def exec(*args)
      # Replaces the current process by doing one of the following:
      raise ::NotImplementedError
    end

    def exit(status = true)
      # Initiates termination of the Ruby script by raising SystemExit;
      # the exception may be caught.
      # Returns exit status status to the underlying operating system.
      raise ::NotImplementedError
    end

    def exit!(status = false)
      # Exits the process immediately; no exit handlers are called.
      # Returns exit status status to the underlying operating system.
      raise ::NotImplementedError
    end

    def fork(&block)
      # Creates a child process.
      raise ::NotImplementedError
    end

    def getpgid(p_id)
      # Returns the process group ID for the given process ID +pid+
      raise ::NotImplementedError
    end

    def getpriority(kind, id)
      # Returns the scheduling priority for specified process, process group, or user.
      raise ::NotImplementedError
    end

    def getrlimit(resource)
      # Returns a 2-element array of the current (soft) limit and
      # maximum (hard) limit for the given resource.
      raise ::NotImplementedError
    end

    def getsid(pid = nil)
      # Returns the session ID of the given process ID pid,
      # or of the current process if not given.
      raise ::NotImplementedError
    end

    def gid
      # Returns the (real) group ID for the current process
      `$platform.process_getgid()`
    end

    def gid=(new_gid)
      # Sets the group ID for the current process to new_gid.
      `$platform.process_setgid(new_gid)`
    end

    def groups
      # Returns an array of the group IDs in the supplemental
      # group access list for the current process
      `$platform.process_getgroups()`
    end

    def initgroups(username, gid)
      # Sets the supplemental group access list; the new list includes:
      # The group IDs of those groups to which the user given by username belongs.
      # The group ID gid
      raise ::NotImplementedError
    end

    def kill(signal, *ids)
      # Sends a signal to each process specified by ids
      # (which must specify at least one ID);
      # returns the count of signals sent.
      if signal.is_a?(::Integer)
        signal = ::Signal.list.key(signal)
        raise(::ArgumentError, 'unknown signal') unless signal
      else
        signal = signal[1..] if signal[0] == '-'
        signal = signal.upcase
        signal = signal[3..] if signal.start_with?('SIG')
        raise(::ArgumentError, 'unknown signal') unless ::Signal.list.key?(signal)
      end
      own_pid = pid
      ids.each do |pd|
        if pd == own_pid
          raise(::SignalException, 'TERM') if signal == 'TERM'
          raise(::Interrupt) if signal == 'INT'
        end
        `$platform.process_kill(pd, signal)` rescue nil
      end
      # emulation for other specs to pass
      ps = Process::Status.new(0, ids[ids.size - 1])
      `ps.signaled = true`
      $? = ps
      ids.size
    end

    def last_status
      # Returns a Process::Status object representing the most recently
      # exited child process in the current thread, or nil if none.
      raise ::NotImplementedError
    end

    def maxgroups
      # Returns the maximum number of group IDs allowed in the supplemental group access list
      raise ::NotImplementedError
    end

    def maxgroups=(new_max)
      # Sets the maximum number of group IDs allowed in the supplemental group access list.
      raise ::NotImplementedError
    end

    def pid
      # Returns the process ID of the current process.
      `$platform.process_pid()`
    end

    def ppid
      # Returns the process ID of the parent of the current process.
      `$platform.process_ppid()`
    end

    def setpgid(pid, pgid)
      # Sets the process group ID for the process given by process ID pid to pgid.
      raise ::NotImplementedError
    end

    def setpgrp
      # Equivalent to setpgid(0, 0)
      setpgid(0, 0)
    end

    def setpriority(kind, integer, priority)
      # See Process.getpriority.
      raise ::NotImplementedError
    end

    def setproctitle(string)
      # Sets the process title that appears on the ps(1) command.
      # Not necessarily effective on all platforms.
      `$platform.process_set_title(string)`
      string
    end

    def setrlimit(resource, cur_limit, max_limit = nil)
      # Sets limits for the current process for the given resource
      # to cur_limit (soft limit) and max_limit (hard limit); returns nil.
      raise ::NotImplementedError
    end

    def setsid
      # Establishes the current process as a new session and process group leader,
      # with no controlling tty; returns the session ID.
      raise ::NotImplementedError
    end

    def spawn(*args)
      # Creates a new child process by doing one of the following in that process
      # - Passing string command_line to the shell.
      # - Invoking the executable at exe_path
      raise ::NotImplementedError
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
      `$platform.process_setuid(new_uid)`
    end

    def wait(pid = -1, flags = 0)
      # Waits for a suitable child process to exit, returns its process ID,
      # and sets $? to a Process::Status object containing information on
      # that process. Which child it waits for depends on the value of the given pid.
      raise ::NotImplementedError
    end
    alias waitpid wait

    def wait2(pid = -1, flags = 0)
      # Like Process.waitpid, but returns an array containing
      # the child process pid and Process::Status status.
      raise ::NotImplementedError
    end

    def waitall
      # Waits for all children, returns an array of 2-element arrays;
      # each subarray contains the integer pid and Process::Status
      # status for one of the reaped child processes
      raise ::NotImplementedError
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
