require 'set'
require 'tilt/opal'
require 'sprockets'
require 'opal/builder'
require 'opal/sprockets/path_reader'
require 'opal/sprockets/source_map_server'

$OPAL_SOURCE_MAPS = {}

module Opal
  # Internal: The Processor class is used to make ruby files (with .rb or .opal
  #   extensions) available to any sprockets based server. Processor will then
  #   get passed any ruby source file to build.
  class Processor < TiltTemplate
    @@cache_key = nil
    def self.cache_key
      @@cache_key ||= ['Opal', Opal::VERSION, Opal::Config.config].to_json.freeze
    end

    def self.reset_cache_key!
      @@cache_key = nil
    end

    def self.call(input)
      output = new(input[:filename]) { input[:data] }.call(input)

      content_type = input[:content_type]
      dirname      = input[:dirname]
      environment  = input[:environment]
      resolver     = -> path { environment.resolve!(path, base_path: dirname, accept: content_type).first }
      required     = Set.new(input[:metadata][:required    ]).merge output[:required    ].map(&resolver)
      dependencies = Set.new(input[:metadata][:dependencies]).merge output[:dependencies].map(&resolver)

      output.merge(required: required, dependencies: dependencies)
    end

    def evaluate(context, _locals, &_block)
      return super unless context.is_a? ::Sprockets::Context

      @sprockets = environment = context.environment

      # In Sprockets 3 logical_path has an odd behavior when the filename is "index"
      # thus we need to bake our own logical_path
      filename = context.respond_to?(:filename) ? context.filename : context.pathname.to_s
      root_path_regexp = Regexp.escape(context.root_path)
      logical_path = filename.gsub(%r{^#{root_path_regexp}/?(.*?)#{sprockets_extnames_regexp}}, '\1')

      output = call(
        environment: environment,
        name: logical_path,
        metadata: {}
      )

      output[:required].each { |required| context.require_asset required }
      output[:dependencies].each { |dependency| context.depend_on dependency }

      output[:data]
    end

    def call(input)
      @sprockets    = sprockets    = input[:environment]
      @logical_path = logical_path = input[:name]
      @required     = Set.new
      @dependencies = Set.new

      compiler_options = self.compiler_options.merge(file: logical_path)

      # Opal will be loaded immediately to as the runtime redefines some crucial
      # methods such that need to be implemented as soon as possible:
      #
      # E.g. It forwards .toString() to .$to_s() for Opal objects including Array.
      #      If .$to_s() is not implemented and some other lib is loaded before
      #      corelib/* .toString results in an `undefined is not a function` error.
      compiler_options.merge!(requirable: false) if logical_path == 'opal'

      compiler = Compiler.new(data, compiler_options)
      result = compiler.compile

      process_requires(compiler.requires)
      process_required_trees(compiler.required_trees)

      if Opal::Config.source_map_enabled
        map_contents = compiler.source_map.as_json.to_json
        ::Opal::SourceMapServer.set_map_cache(sprockets, logical_path, map_contents)
      end

      {
        data: result.to_s,
        required: @required,
        dependencies: @dependencies,
      }
    end

    def self.sprockets_extnames(sprockets)
      ['.js']+sprockets.engines.keys
    end

    def self.sprockets_extnames_regexp(sprockets)
      joined_extnames = sprockets_extnames(sprockets).map { |ext| Regexp.escape(ext) }.join('|')
      Regexp.new("(#{joined_extnames})*$")
    end

    def sprockets_extnames_regexp
      @sprockets_extnames_regexp ||= self.class.sprockets_extnames_regexp(@sprockets)
    end

    def process_requires(requires)
      requires.each do |required|
        required = required.to_s.sub(sprockets_extnames_regexp, '')
        @required << required unless ::Opal::Config.stubbed_files.include? required
      end
    end

    # Internal: Add files required with `require_tree` as asset dependencies.
    #
    # Mimics (v2) Sprockets::DirectiveProcessor#process_require_tree_directive
    def process_required_trees(required_trees)
      return if required_trees.empty?

      # This is the root dir of the logical path, we need this because
      # the compiler gives us the path relative to the file's logical path.
      dirname = File.dirname(file).gsub(/#{Regexp.escape File.dirname(@logical_path)}#{REGEXP_END}/, '')
      dirname = Pathname(dirname)

      required_trees.each do |original_required_tree|
        required_tree = Pathname(original_required_tree)

        unless required_tree.relative?
          raise ArgumentError, "require_tree argument must be a relative path: #{required_tree.inspect}"
        end

        required_tree = dirname.join(file, '..', required_tree)

        unless required_tree.directory?
          raise ArgumentError, "require_tree argument must be a directory: #{{source: original_required_tree, pathname: required_tree}.inspect}"
        end

        @dependencies << required_tree.to_s
        environment = @environment

        processor = ::Sprockets::DirectiveProcessor.new
        processor.instance_variable_set('@dirname', File.dirname(file))
        processor.instance_variable_set('@environment', environment)
        path = processor.__send__(:expand_relative_dirname, :require_tree, original_required_tree)
        absolute_paths = environment.__send__(:stat_sorted_tree_with_dependencies, path).first.map(&:first)

        absolute_paths.each do |path|
          path = Pathname(path)
          pathname = path.relative_path_from(dirname).to_s

          case
          when name.to_s == file
            next
          when path.directory?
            @dependencies << path.to_s
          else
            @required << pathname
          end
        end
      end
    end

    # @deprecated
    def self.stubbed_files
      warn "Deprecated: `::Opal::Processor.stubbed_files' is deprecated, use `::Opal::Config.stubbed_files' instead"
      puts caller(5)
      ::Opal::Config.stubbed_files
    end

    # @deprecated
    def self.stub_file(name)
      warn "Deprecated: `::Opal::Processor.stub_file' is deprecated, use `::Opal::Config.stubbed_files << #{name.inspect}.to_s' instead"
      puts caller(5)
      ::Opal::Config.stubbed_files << name.to_s
    end


    private

    def stubbed_files
      ::Opal::Config.stubbed_files
    end
  end
end


case
when Sprockets.respond_to?(:register_transformer)
  Sprockets.register_mime_type 'application/ruby', extensions: %w[.rb .js.rb .opal .js.opal], charset: :unicode
  Sprockets.register_transformer 'application/ruby', 'application/javascript', Opal::Processor
  Sprockets.register_preprocessor 'application/ruby', Sprockets::DirectiveProcessor.new(comments: ['#'])

when Sprockets.respond_to?(:register_engine)
  Sprockets.register_engine '.rb',    Opal::Processor
  Sprockets.register_engine '.opal',  Opal::Processor
end
