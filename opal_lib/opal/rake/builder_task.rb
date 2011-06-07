require 'rake'
require 'rake/tasklib'

module Opal
  module Rake

    class BuilderTask < ::Rake::TaskLib

      attr_accessor :files

      attr_accessor :out

      attr_accessor :main

      attr_accessor :watch

      def initialize(name = :opal)
        @name    = name
        @files   = []
        @out     = nil
        @main    = nil
        @watch   = false

        yield self if block_given?
        define_rake_task
      end

      def define_rake_task
        desc "Build opal files"
        task(@name) do
          options = {}
          options[:files] = @files
          options[:out]   = @out if @out
          options[:main]  = @main if @main
          options[:watch] = @watch

          builder = Opal::Builder.new
          builder.build options
        end
      end
    end
  end
end

