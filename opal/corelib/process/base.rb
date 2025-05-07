# backtick_javascript: true

class ::Signal
  def self.trap(*)
  end

  def self.list
    `Opal.platform.process_sig_list`
  end
end

class ::GC
  def self.start
  end
end
