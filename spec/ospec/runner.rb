require 'ospec/phantom'

module MSpec
  def self.opal_runner
    @env = Object.new
    @env.extend MSpec
  end
end

class OSpecRunner
  def self.main
    return @main if @main

    @main = self.new
  end

  def initialize(*)
  end

  def register
    formatter = PhantomFormatter.new
    formatter.register
  end

  def run
    MSpec.opal_runner
  end
end

main = OSpecRunner.main
main.register
main.run
