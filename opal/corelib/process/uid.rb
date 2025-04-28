require 'etc'

module ::Process
  module UID
    def change_privilege(uid)
      ::Process.uid = uid
      ::Process.euid = uid
    end
    module_function :change_privilege

    def eid
      ::Process.euid
    end
    module_function :eid

    def from_name(name)
      Etc.getpwnam(name).uid
    end
    module_function :from_name

    def grant_privilege(id)
      ::Process.euid = uid
    end
    module_function :grant_privilege

    def re_exchange
      uid = ::Process.uid
      Process.uid = ::Process.euid
      Process.euid = uid
    end
    module_function :re_exchange

    def re_exchangeable?
      true
    end
    module_function :re_exchangeable?

    def rid
      ::Process.uid
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
