require 'rake'
require 'rake/tasklib'

module Opal

  module Rake

    class SpecTask < ::Rake::TaskLib

      def initialize(name = :spec)
        @name = name
        yield self if block_given?
        define
      end

      def define
        desc "Build ospec files ready for browser"
        task(@name) do
          base = File.basename Dir.getwd
          gem = Opal::Gem.new Dir.getwd
          content = gem.bundle :dependencies => 'ospec',
            :main => 'ospec/autorun', :test_files => true

          File.open("tmp/#{base}.spec.js", 'w+') do |out|
            out.write content
          end
        end
      end
    end
  end
end

