module ::Process
  class Status
    def initialize(status, pid)
      @status, @pid = status, pid
    end

    attr_reader :pid

    def exitstatus
      @status
    end

    def inspect
      "#<Process::Status: pid #{@pid} exit #{@status}>"
    end

    def signaled?
      @signaled
    end

    def success?
      @status == 0
    end
  end
end
