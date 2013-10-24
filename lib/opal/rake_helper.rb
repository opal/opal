require 'opal'

module Opal
  class RakeHelper
    include Rake::DSL if defined? Rake::DSL

    class << self
      attr_accessor :instance

      def install_tasks
        self.new.install_tasks
      end

      def expose(*names)
        names.each do |name|
          define_singleton_method(name) do |*args|
            instance.__send__(name, *args)
          end
        end
      end
    end

    expose :uglify, :gzip

    def initialize
      install_tasks

      RakeHelper.instance = self
    end

    def install_tasks
      namespace :opal do
      end
    end

    def uglify(str)
      IO.popen('uglifyjs', 'r+') do |i|
        i.puts str
        i.close_write
        return i.read
      end
    end

    def gzip(str)
      IO.popen('gzip -f', 'r+') do |i|
        i.puts str
        i.close_write
        return i.read
      end
    end
  end
end
