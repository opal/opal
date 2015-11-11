module KernelExit
  extend self
  attr_accessor :status, :original_proc, :proc, :out

  self.original_proc = `Opal.exit`
  self.proc = `function(status){ #{KernelExit.status = `status`} }`

  def out_after_exit
    `Opal.exit = #{proc}`
    exit
    out
  ensure
    `Opal.exit = #{original_proc}`
  end

  def reset!
    self.out = []
  end
end

describe "Kernel.at_exit" do
  before { KernelExit.reset! }

  def print(n)
    KernelExit.out << n
  end

  it "runs after all other code" do
    Kernel.at_exit {print 5}
    print 6

    KernelExit.out_after_exit.should == [6,5]
  end

  it "runs in reverse order of registration" do
    at_exit {print 4}
    at_exit {print 5}
    print 6
    at_exit {print 7}

    KernelExit.out_after_exit.should == [6,7,5,4]
  end

  it "allows calling exit inside at_exit handler" do
    at_exit {print 3}
    at_exit {
      print 4
      exit
      # print 5 # This one is added to out because Opal.exit doesn't actually exit
    }
    at_exit {print 6}

    KernelExit.out_after_exit.should == [6,4,3]
  end

  # INCOMPLETE: the spec implementation is tricky here
  # it "gives access to the last raised exception" do
  #   begin
  #     at_exit do
  #       print $!.message
  #     end
  #     raise 'foo' rescue nil
  #     p [:err, $!]
  #   rescue
  #   end
  #
  #   KernelExit.out_after_exit.should == ['foo']
  # end

end
