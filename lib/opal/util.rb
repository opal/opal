# frozen_string_literal: true

require 'open3'

module Opal
  module Util
    extend self

    ExitStatusError = Class.new(StandardError)

    # Used for uglifying source to minify.
    #
    #     Opal::Util.uglify("javascript contents")
    #
    # @param str [String] string to minify
    # @return [String]
    def uglify(source, mangle: false)
      sh "bin/yarn -s run terser -c #{'-m' if mangle}", data: source
    end

    # Gzip code to check file size.
    def gzip(source)
      sh 'gzip -f', data: source
    end

    private

    def sh(command, data:)
      out, _err, status = Open3.capture3(command, stdin_data: data)
      raise ExitStatusError, "exited with status #{status.exitstatus}" unless status.success?
      out
    end
  end
end
