require 'ospec/phantom'

module MSpec
  def self.opal_runner
    @env = Object.new
    @env.extend MSpec
  end
end

# Add keys to pending array as names of specs not to run.
class OSpecFilter
  def initialize
    @pending = {}
  end

  def register
    MSpec.register :exclude, self
  end

  def ===(string)
    @pending.has_key? string
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

    filter = OSpecFilter.new
    filter.register
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
