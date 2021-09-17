# frozen_string_literal: true

require 'mini_racer'
require 'opal/paths'

module Opal
  module CliRunners
    class MiniRacer
      def self.call(data)
        ::MiniRacer::Platform.set_flags! :harmony

        builder = data.fetch(:builder)
        output = data.fetch(:output)
        # TODO: pass it
        argv = data.fetch(:argv)

        v8 = ::MiniRacer::Context.new
        v8.attach('prompt', ->(_msg = '') { $stdin.gets&.chomp })
        v8.attach('console.log', ->(i) { output.print(i); output.flush })
        v8.attach('console.warn', ->(i) { $stderr.print(i); $stderr.flush })
        v8.attach('crypto.randomBytes', method(:random_bytes).to_proc)
        v8.attach('opalminiracer.exit', ->(status) { Kernel.exit(status) })
        v8.attach('opalminiracer.argv', argv)

        code = builder.to_s + "\n" + builder.source_map.to_data_uri_comment

        v8.eval(code)
      end

      # A polyfill so that SecureRandom works in repl correctly.
      def self.random_bytes(bytes)
        ::SecureRandom.bytes(bytes).split('').map(&:ord)
      end
    end
  end
end
