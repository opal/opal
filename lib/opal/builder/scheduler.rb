# frozen_string_literal: true

require 'opal/os' unless RUBY_ENGINE == 'opal'

module Opal
  class Builder
    class Scheduler
      def initialize(builder)
        @builder = builder
      end

      attr_accessor :builder

      # Prefork is not deterministic. This module corrects an order of processed
      # files so that it would be exactly the same as if building sequentially.
      # While for Ruby files it usually isn't a problem, because the real order
      # stems from how `Opal.modules` array is accessed, the JavaScript files
      # are executed verbatim and their order may be important. Also, having
      # deterministic output is always a good thing.
      module OrderCorrector
        module_function

        def correct_order(processed, requires, builder)
          # Let's build a hash that maps a filename to an array of files it requires
          requires_hash = processed.to_h do |i|
            [i.filename, expand_requires(i.requires, builder)]
          end
          # Let's build an array with a correct order of requires
          order_array = build_require_order_array(expand_requires(requires, builder), requires_hash)
          # If a key is duplicated, remove the last duplicate
          order_array = order_array.uniq
          # Create a hash from this array: [a,b,c] => [a => 0, b => 1, c => 2]
          order_hash = order_array.each_with_index.to_h
          # Let's return a processed array that has elements in the order provided
          processed.sort_by do |asset|
            # If a filename isn't present somehow in our hash, let's put it at the end
            order_hash[asset.filename] || order_array.length
          end
        end

        # Expand a requires array, so that the requires filenames will be
        # matching Builder::Processor#. Builder needs to be passed so that
        # we can access an `expand_ext` function from its context.
        def expand_requires(requires, builder)
          requires.map { |i| builder.expand_ext(i) }
        end

        def build_require_order_array(requires, requires_hash, built_for = Set.new)
          array = []
          requires.each do |name|
            next if built_for.include?(name)
            built_for << name

            asset_requires = requires_hash[name]
            array += build_require_order_array(asset_requires, requires_hash, built_for) if asset_requires
            array << name
          end
          array
        end
      end
    end
  end

  singleton_class.attr_accessor :builder_scheduler

  if RUBY_ENGINE != 'opal'
    if RUBY_ENGINE == 'ruby'
      # Windows has a faulty `fork`.
      if OS.windows? || ENV['OPAL_PREFORK_DISABLE']
        require 'opal/builder/scheduler/sequential'
        Opal.builder_scheduler = Builder::Scheduler::Sequential
      else
        require 'opal/builder/scheduler/prefork'
        Opal.builder_scheduler = Builder::Scheduler::Prefork
      end
    elsif %w[jruby truffleruby].include?(RUBY_ENGINE)
      if RUBY_ENGINE == 'truffleruby' && !ENV['RUBYOPT'].include?('--vm.XX:StackSize')
        warn <<~TEXT
          Recommendation:
          If you encounter "IndexOutOfBound", "Stack level too deep" or similar errors,
          please ensure the per thread stack size for truffleruby is at least 2MB.
          Via environment variable: export RUBYOPT="--vm.XX:StackSize=2097152"
        TEXT
      end
      require 'opal/builder/scheduler/threaded'
      Opal.builder_scheduler = Builder::Scheduler::Threaded
    else
      require 'opal/builder/scheduler/sequential'
      Opal.builder_scheduler = Builder::Scheduler::Sequential
    end
  else
    require 'opal/builder/scheduler/sequential'
    Opal.builder_scheduler = Builder::Scheduler::Sequential
  end
end
