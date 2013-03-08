require 'ospec/phantom'
require 'ospec/filter'

# stdlib
require 'opal/date'
require 'opal/enumerator'

ENV = {}

class File
  def self.expand_path(*a); nil; end
end

module Kernel
  def opal_eval(str)
    code = Opal::Parser.new.parse str
    `eval(#{code})`
  end

  def opal_parse(str, file='(string)')
    Opal::Grammar.new.parse str, file
  end

  def opal_eval_compiled(javascript)
    `eval(javascript)`
  end

  def eval(str)
    opal_eval str
  end
end

module Kernel
  # FIXME: remove
  def ruby_version_is(*); end
  def pending(*); end
end

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

