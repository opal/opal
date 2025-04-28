require 'etc'

module ::Process
  module GID
    def change_privilege(gid)
      ::Process.gid = gid
      ::Process.egid = gid
    end
    module_function :change_privilege

    def eid
      ::Process.egid
    end
    module_function :eid

    def from_name(name)
      Etc.getgrnam(name).gid
    end
    module_function :from_name

    def grant_privilege(gid)
      ::Process.egid = gid
    end
    module_function :grant_privilege

    def re_exchange
      gid = ::Process.gid
      Process.gid = ::Process.egid
      Process.egid = gid
    end
    module_function :re_exchange

    def re_exchangeable?
      true
    end
    module_function :re_exchangeable?

    def rid
      ::Process.gid
    end
    module_function :rid

    def sid_available?
      false
    end

    def switch(&block)
      return re_exchange unless block_given?
      begin
        return yield
      ensure
        re_exchange
      end
    end
    module_function :switch
  end
end
