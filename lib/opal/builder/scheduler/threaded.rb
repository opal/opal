# frozen_string_literal: true

module Opal
  class Builder
    class Scheduler
      class Threaded < Scheduler
        def initialize(builder)
          super(builder)
          @threads = []
          @threads_mutex = Thread::Mutex.new
          init_thread_args
        end

        # We hook into the process_requires method
        def process_requires(rel_path, requires, autoloads, options)
          return if requires.empty?

          first_run = threaded_reactor(rel_path, requires, autoloads, options)

          if first_run
            processed = OrderCorrector.correct_order(@thread_args[:processed], requires, builder)
            builder.processed.append(*processed)
            init_thread_args
          end
        end

        private

        def init_thread_args
          @thread_args = {
            queue: [],
            queue_mutex: Thread::Mutex.new,
            processed: [],
            processed_req: {},
            processed_mutex: Thread::Mutex.new,
          }
        end

        # By default we use 3/4 of CPU threads detected.
        def thread_count
          ENV['OPAL_PREFORK_THREADS']&.to_i || ((n = Etc.nprocessors) > 8 ? (n * 3 / 4.0).ceil : n)
        end

        def create_thread(execution)
          Thread.new(@thread_args, execution, builder) do |args, exe, builder|
            todo = nil
            shall_skip = false

            while exe[:continue]
              todo = nil
              args[:queue_mutex].synchronize do
                todo = args[:queue].shift
                exe[:busy] += 1 if todo
              end

              unless todo
                sleep 0.01 # to keep things simple and prevent busy looping
                next
              end

              rel_path, req, autoloads, options = *todo

              begin
                args[:processed_mutex].synchronize do
                  shall_skip = builder.already_processed.include?(req)
                  builder.already_processed << req unless shall_skip
                end

                next if shall_skip

                asset = builder.process_require_threadsafely(req, autoloads, options)
                if asset
                  args[:processed_mutex].synchronize { args[:processed] << asset }
                end
              rescue Builder::MissingRequire => error
                args[:queue_mutex].synchronize do
                  exe[:continue] = false
                  exe[:busy] = 0
                  args[:exception] = Builder::MissingRequire.new "A file required by #{rel_path.inspect} wasn't found.\n#{error.message}", error.backtrace
                end
              rescue => error
                args[:queue_mutex].synchronize do
                  exe[:continue] = false
                  exe[:busy] = 0
                  args[:exception] = error
                end
              ensure
                args[:queue_mutex].synchronize do
                  exe[:busy] -= 1
                  exe[:continue] = false if args[:queue].empty? && exe[:busy] <= 0
                end
              end
            end
          end
        end

        def run_threads
          execution = { continue: true, busy: 0 }

          @threads_mutex.synchronize do
            thread_count.times do
              @threads << create_thread(execution)
            end
          end

          @threads.each(&:join)

          @threads_mutex.synchronize { @threads.clear }

          exception = @thread_args[:exception]

          raise exception if exception
        end

        def threaded_reactor(rel_path, requires, autoloads, options)
          first_run = @threads_mutex.synchronize { @threads.empty? }

          @thread_args[:queue_mutex].synchronize do
            requires.each do |req|
              @thread_args[:queue] << [rel_path, req, autoloads, options]
            end
          end

          run_threads if first_run

          first_run
        end
      end
    end
  end
end
