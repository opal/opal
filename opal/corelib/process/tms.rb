module Process
  class Tms
    # User CPU time
    attr_reader :utime

    # System CPU time
    attr_reader :stime

    # User CPU time of children
    attr_reader :cutime

    # System CPU time of children
    attr_reader :cstime

    def initialize(utime = 0.0, stime = 0.0, cutime = 0.0, cstime = 0.0)
      @utime, @stime, @cutime, @cstime = utime, stime, cutime, cstime
    end
  end
end
