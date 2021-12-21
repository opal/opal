module ::Process
  class Status
    def initialize(status, pid)
      @status, @pid = status, pid
    end

    def exitstatus
      @status
    end

    attr_reader :pid

    def success?
      @status == 0
    end

    def inspect
      "#<Process::Status: pid #{@pid} exit #{@status}>"
    end
  end
end
