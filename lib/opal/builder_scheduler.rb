# frozen_string_literal: true

require 'opal/os' unless RUBY_ENGINE == 'opal'

module Opal
  class BuilderScheduler
    def initialize(builder)
      @builder = builder
    end

    attr_accessor :builder
  end

  singleton_class.attr_accessor :builder_scheduler

  if RUBY_ENGINE != 'opal'
    # Windows has a faulty `fork`.
    if OS.windows? || ENV['OPAL_PREFORK_DISABLE']
      require 'opal/builder_scheduler/sequential'
      Opal.builder_scheduler = BuilderScheduler::Sequential
    else
      require 'opal/builder_scheduler/prefork'
      Opal.builder_scheduler = BuilderScheduler::Prefork
    end
  else
    require 'opal/builder_scheduler/sequential'
    Opal.builder_scheduler = BuilderScheduler::Sequential
  end
end
