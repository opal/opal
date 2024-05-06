# frozen_string_literal: true

require 'opal/os' unless RUBY_ENGINE == 'opal'

module Opal
  class Builder
    class Scheduler
      def initialize(builder)
        @builder = builder
      end

      attr_accessor :builder
    end
  end

  singleton_class.attr_accessor :builder_scheduler

  if RUBY_ENGINE != 'opal'
    # Windows has a faulty `fork`.
    if OS.windows? || ENV['OPAL_PREFORK_DISABLE']
      require 'opal/builder/scheduler/sequential'
      Opal.builder_scheduler = Builder::Scheduler::Sequential
    else
      require 'opal/builder/scheduler/prefork'
      Opal.builder_scheduler = Builder::Scheduler::Prefork
    end
  else
    require 'opal/builder/scheduler/sequential'
    Opal.builder_scheduler = Builder::Scheduler::Sequential
  end
end
