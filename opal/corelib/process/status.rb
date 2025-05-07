module ::Process
  class Status
    def self.wait(pid = -1, flags = 0)
      # Like Process.wait, but returns a Process::Status object (instead of an integer pid or nil)
      _pid, status = ::Process.wait2(pid, flag)
      status
    end

    def initialize(status, pid)
      @status, @pid = status, pid
    end

    def ==(other)
      # Returns whether the value of to_i == other
      to_i == other
    end

    # Returns true if the process generated a coredump when it terminated, false if not.
    def coredump?
      __not_implemented__
    end

    # Returns true if the process exited normally (for example using an exit()
    # call or finishing the program), false if not.
    def exited?
      !@status.nil?
    end

    def exitstatus
      # Returns the least significant eight bits of the return code of the process if it has exited
      @status & 0xFF if exited?
    end

    def inspect
      # Returns a string representation of self
      "#<Process::Status: pid #{@pid} exit #{@status}>"
    end

    attr_reader :pid # Returns the process ID of the process

    # Returns true if the process terminated because of an uncaught signal, false otherwise.
    def signaled?
      __not_implemented__
    end

    # Returns true if this process is stopped, and if the corresponding wait call
    # had the Process::WUNTRACED flag set, false otherwise.
    def stopped?
      __not_implemented__
    end

    # Returns the number of the signal that caused the process to stop, or nil if the process is not stopped.
    def stopsig
      __not_implemented__
    end

    def success?
      # Returns:
      #   true if the process has completed successfully and exited.
      #   false if the process has completed unsuccessfully and exited.
      #   nil if the process has not exited.
      @status == 0 if exited?
    end

    # Returns the number of the signal that caused the process to terminate
    # or nil if the process was not terminated by an uncaught signal.
    def termsig
      __not_implemented__
    end

    def to_s
      "pid #{@pid} exit #{@status}"
    end
  end
end
