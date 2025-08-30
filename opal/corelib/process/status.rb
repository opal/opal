module ::Process
  class Status
    # status interpretation flags:
    # PROCESS_CONTINUED  1
    # PROCESS_COREDUMPED 2
    # PROCESS_EXITED     4
    # PROCESS_SIGNALED   8
    # PROCESS_STOPPED   16

    def self.wait(pid = -1, flags = 0)
      # Like Process.wait, but returns a Process::Status object (instead of an integer pid or nil)
      _pid, status = ::Process.wait2(pid, flag)
      status
    end

    def initialize(status, pid)
      # status must be a JS object with keys:
      #   status: return code, integer
      #   flags: see flags above, integer, for normal exit use 4
      #   signal: only used if flags SIGNALED or STOPPED are used, integer
      @status = status
      @pid = pid
    end

    def ==(other)
      # Returns whether the value of to_i == other
      to_i == other
    end

    # Returns true if the process generated a coredump when it terminated, false if not.
    def coredump?
      @status.JS[:flags] & 2 == 2
    end

    # Returns true if the process exited normally (for example using an exit()
    # call or finishing the program), false if not.
    def exited?
      @status.JS[:flags] & 4 == 4
    end

    def exitstatus
      # Returns the least significant eight bits of the return code of the process if it has exited
      @status.JS[:status] || nil
    end

    def inspect
      # Returns a string representation of self
      "#<Process::Status: pid #{@pid} exit #{exitstatus}>"
    end

    attr_reader :pid # Returns the process ID of the process

    # Returns true if the process terminated because of an uncaught signal, false otherwise.
    def signaled?
      @status.JS[:flags] & 8 == 8
    end

    # Returns true if this process is stopped, and if the corresponding wait call
    # had the Process::WUNTRACED flag set, false otherwise.
    def stopped?
      @status.JS[:flags] & 16 == 16
    end

    # Returns the number of the signal that caused the process to stop, or nil if the process is not stopped.
    def stopsig
      @status.JS[:signal] if stopped?
    end

    def success?
      # Returns:
      #   true if the process has completed successfully and exited.
      #   false if the process has completed unsuccessfully and exited.
      #   nil if the process has not exited.
      exited? ? @status.JS[:status] == 0 : nil
    end

    # Returns the number of the signal that caused the process to terminate
    # or nil if the process was not terminated by an uncaught signal.
    def termsig
      @status.JS[:signal] if signaled?
    end

    def to_s
      "pid #{@pid} exit #{exitstatus}"
    end
  end
end
