# frozen_string_literal: true

module Opal
  class Builder
    class Scheduler
      class Sequential < Scheduler
        def process_requires(rel_path, requires, autoloads, options)
          requires.map { |r| builder.process_require(r, autoloads, options) }
        rescue Builder::MissingRequire => error
          raise error, "A file required by #{rel_path.inspect} wasn't found.\n#{error.message}", error.backtrace
        end
      end
    end
  end
end
