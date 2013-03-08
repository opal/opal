require 'ospec/phantom'
require 'ospec/filter'

module MSpec
  def self.opal_runner
    @env = Object.new
    @env.extend MSpec
  end
end

class OSpecRunner
  def self.main
    @main ||= self.new
  end

  def initialize
    register
    run
  end

  def register
    formatter = PhantomFormatter.new
    formatter.register

    OSpecFilter.main.register
  end

  def run
    MSpec.opal_runner
  end

  def will_start
    MSpec.actions :start
  end

  def did_finish
    MSpec.actions :finish
  end
end

# As soon as this file loads, tell the runner the specs are starting
OSpecRunner.main.will_start

