module ::Process
  module Sys
    def getegid
      ::Process.egid
    end
    module_function :getegid

    def geteuid
      ::Process.euid
    end
    module_function :geteuid

    def getgid
      ::Process.gid
    end
    module_function :getgid

    def getuid
      ::Process.uid
    end
    module_function :getuid

    alias issetugid __not_implemented__
    module_function :issetugid

    def setegid(gid)
      ::Process.egid = gid
      nil
    end
    module_function :setegid

    def seteuid(uid)
      ::Process.euid = uid
      nil
    end
    module_function :seteuid

    def setgid(gid)
      ::Process.gid = gid
      nil
    end
    module_function :setgid

    def setregid(rid, eid)
      setgid(rid) unless rid == -1
      setegid(eid) unless eid == -1
      nil
    end
    module_function :setregid

    alias setresgid __not_implemented__
    module_function :setresgid

    alias setresuid __not_implemented__
    module_function :setresuid

    def setreuid(rid, eid)
      setuid(rid) unless rid == -1
      seteuid(eid) unless eid == -1
      nil
    end
    module_function :setreuid

    def setuid(uid)
      ::Process.uid = uid
      nil
    end
    module_function :setuid
  end
end
