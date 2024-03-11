# backtick_javascript: true

module ::Process
  def self.pid
    `Opal.Kernel.__process__.pid`
  end
end
