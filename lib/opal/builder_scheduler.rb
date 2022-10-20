# frozen_string_literal: true

module Opal
  class BuilderScheduler
    def initialize(builder)
      @builder = builder
    end

    attr_reader :builder
  end

  singleton_class.attr_accessor :builder_scheduler

  if RUBY_ENGINE != 'opal'
    # Windows has a faulty `fork`.
    if Gem.win_platform? || ENV['OPAL_PREFORK_DISABLE']
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
