# backtick_javascript: true

module ::Signal
  def self.list
    # Returns a list of signal names mapped to the corresponding underlying signal numbers.
    `Opal.platform.process_sig_list`
  end

  def self.signame(signo)
    # Convert signal number to signal name. Returns nil if the signo is an invalid signal number.
    signo = ::Opal.coerce_to!(signo, ::Integer, :to_int)
    `Opal.platform.process_sig_list`.key(signo)
  end

  def self.trap(signal, command = nil, &block)
    # Specifies the handling of signals. The first parameter is a signal name
    # (a string such as “SIGALRM”, “SIGUSR1”, and so on) or a signal number.
    # The command or block specifies code to be run when the signal is raised.
    ::Kernel.trap(signal, command, &block)
  end
end

class ::GC
  def self.start
  end
end
