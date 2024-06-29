# frozen_string_literal: true

require 'opal/compiler'
require 'opal/erb'
require 'erb'

module Opal
  class Builder
    class Processor
      def initialize(orig_source, filename, abs_path = nil, options = {})
        if abs_path.is_a? Hash
          options = abs_path
          abs_path = nil
        end
        self.source = orig_source
        @filename, @abs_path, @options = filename, abs_path, options.dup
        @cache = @options.delete(:cache) { Opal.cache }
        @requires = []
        @required_trees = []
        @autoloads = []
        @mtime = file_mtime
      end
      attr_reader :source, :filename, :options, :requires, :required_trees, :autoloads, :abs_path

      alias original_source source

      def source=(src)
        src += "\n" unless src.end_with?("\n")
        @source = src
      end

      def update(new_source)
        @mtime = file_mtime
        self.source = new_source
      end

      def file_mtime
        File::Stat.new(@abs_path).mtime if @abs_path
      end

      def changed?
        if @abs_path
          return :removed unless File.exist?(@abs_path)
          return :modified unless file_mtime == @mtime
        end
        :no
      end

      def to_s
        source.to_s
      end

      class << self
        attr_reader :extensions

        def handles(*extensions)
          @extensions = extensions
          matches = extensions.join('|')
          matches = "(#{matches})" unless extensions.size == 1
          @match_regexp = Regexp.new "\\.#{matches}#{REGEXP_END}"

          ::Opal::Builder.register_processor(self, extensions)
          nil
        end

        def match?(other)
          other.is_a?(String) && other.match(match_regexp)
        end

        def match_regexp
          @match_regexp || raise(NotImplementedError)
        end
      end

      def mark_as_required(filename)
        "Opal.loaded([#{filename.to_s.inspect}]);"
      end

      class JsProcessor < Processor
        handles :js

        ManualFragment = Struct.new(:line, :column, :code, :source_map_name)

        def source_map
          @source_map ||= begin
            manual_fragments = source.each_line.with_index.map do |line_source, index|
              column = line_source.index(/\S/)
              line = index + 1
              ManualFragment.new(line, column, line_source, nil)
            end

            ::Opal::SourceMap::File.new(manual_fragments, filename, source)
          end
        end

        def source
          @source.to_s + mark_as_required(@filename)
        end

        def update(new_source)
          super
          @source_map = nil
        end
      end

      class RubyProcessor < Processor
        handles :rb, :opal

        def source
          compiled.result
        end

        def source_map
          compiled.source_map
        end

        def compiled
          @compiled ||= Opal::Cache.fetch(@cache, cache_key) do
            compiler = compiler_for(@source, file: @filename)
            compiler.compile
            compiler
          end
          @required_trees_mtime ||= rts_mtime(@compiled)
          @compiled
        end

        def cache_key
          [self.class, @filename, @source, @options, @mtime]
        end

        def compiler_for(source, options = {})
          ::Opal::Compiler.new(source, @options.merge(options))
        end

        def requires
          compiled.requires
        end

        def required_trees
          compiled.required_trees
        end

        def autoloads
          compiled.autoloads
        end

        def update(new_source)
          super
          @compiled = nil
        end

        # Also catch a files with missing extensions and nil.
        def self.match?(other)
          super || File.extname(other.to_s) == ''
        end

        def rts_mtime(compiler)
          if compiler&.required_trees&.any? && abs_path
            dir = File.dirname(abs_path)
            rt_mtimes = compiler.required_trees.map do |path|
              rt_path = File.expand_path("#{dir}/#{path}")
              Dir.each_child(rt_path).map { |file| File::Stat.new("#{dir}/#{path}/#{file}").mtime }.sort.last
            end
            rt_mtimes.sort.last
          end
        end

        def changed?
          res = super
          return :modified if res == :no && @compiled&.required_trees&.any? && rts_mtime(@compiled) != @required_trees_mtime
          res
        end
      end

      # This handler is for files named ".opalerb", which ought to
      # first get compiled to Ruby code using ERB, then with Opal.
      # Unlike below processors, OpalERBProcessor can be used to
      # compile templates, which will in turn output HTML. Take
      # a look at docs/templates.md to understand this subsystem
      # better.
      class OpalERBProcessor < RubyProcessor
        handles :opalerb

        def initialize(*args)
          super
          @source = prepare(@source, @filename)
        end

        def requires
          ['erb'] + super
        end

        def update(new_source)
          super
          @source = prepare(@source, @filename)
          @compiled = nil
        end

        private

        def prepare(source, path)
          ::Opal::ERB::Compiler.new(source, path).prepared_source
        end
      end

      # This handler is for files named ".rb.erb", which ought to
      # first get preprocessed via ERB, then via Opal.
      class RubyERBProcessor < RubyProcessor
        handles :"rb.erb"

        def compiled
          @compiled ||= begin
            erb = ::ERB.new(@source.to_s)
            erb.filename = @abs_path

            @source = erb.result

            compiler = compiler_for(@source, file: @filename)
            compiler.compile
            compiler
          end
        end
      end

      # This handler is for files named ".js.erb", which ought to
      # first get preprocessed via ERB, then served verbatim as JS.
      class ERBProcessor < Processor
        handles :erb

        def source
          erb = ::ERB.new(@source.to_s)
          erb.filename = @abs_path

          result = erb.result
          module_name = ::Opal::Compiler.module_name(@filename)
          "Opal.modules[#{module_name.inspect}] = function() {#{result}};"
        end
      end
    end
  end
end
