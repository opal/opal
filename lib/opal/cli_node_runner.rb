require 'opal/util'

module Opal
  class CliNodeRunner
    def initialize(output)
      @output ||= output
    end
    attr_reader :output

    def puts(*args)
      output.puts(*args)
    end

    def run(code)
      require 'open3'
      begin
        stdin, stdout, stderr = Open3.popen3('node')
      rescue Errno::ENOENT
        raise MissingNodeJS, 'Please install Node.js to be able to run Opal scripts.'
      end

      stdin.write code
      stdin.close

      [stdout, stderr].each do |io|
        str = io.read
        puts str unless str.empty?
      end
    end

    class MissingNodeJS < StandardError
    end
  end
end
