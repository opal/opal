# frozen_string_literal: true

require 'mini_racer'
require 'opal/paths'

module Opal
  module CliRunners
    class MiniRacer
      def self.call(data)
        ::MiniRacer::Platform.set_flags! :harmony

        builder = data.fetch(:builder).call
        output = data.fetch(:output)
        # TODO: pass it
        argv = data.fetch(:argv)

        # MiniRacer doesn't like to fork. Let's build Opal first
        # in a forked environment.
        code = builder.compiled_source

        v8 = ::MiniRacer::Context.new
        v8.attach('prompt', ->(_msg = '') { $stdin.gets&.chomp })
        v8.attach('console.log', ->(i) { output.print(i); output.flush })
        v8.attach('console.warn', ->(i) { $stderr.print(i); $stderr.flush })
        v8.attach('crypto.randomBytes', method(:random_bytes).to_proc)
        v8.attach('opalminiracer.exit', ->(status) { Kernel.exit(status) })
        v8.attach('opalminiracer.argv', argv)

        v8.eval(code)
        0
      end

      # A polyfill so that SecureRandom works in repl correctly.
      def self.random_bytes(bytes)
        ::SecureRandom.bytes(bytes).split('').map(&:ord)
      end
    end
  end
end
