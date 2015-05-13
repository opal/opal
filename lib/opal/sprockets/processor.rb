require 'set'
require 'tilt/opal'
require 'sprockets'
require 'opal/builder'
require 'opal/sprockets/path_reader'
require 'opal/sprockets/source_map_server'

$OPAL_SOURCE_MAPS = {}

module Opal
  # The Processor class is used to make ruby files (with rb or opal extensions)
  # available to any sprockets based server. Processor will then get passed any
  # ruby source file to build.
  class Processor < TiltTemplate
    # DEPRECATED:
    # Support legacy accessors to default options, now moved to Opal::Config
    Opal::Config.default_config.keys.each do |config_option|
      define_singleton_method(config_option) { Opal::Config.config[config_option] }
      define_singleton_method("#{config_option}=") { |value| Opal::Config.config[config_option] = value }
    end

    def evaluate(context, locals, &block)
      return super unless context.is_a? ::Sprockets::Context

      @sprockets = sprockets = context.environment

      # In Sprockets 3 logical_path has an odd behavior when the filename is "index"
      # thus we need to bake our own logical_path
      filename = context.respond_to?(:filename) ? context.filename : context.pathname.to_s
      logical_path = filename.sub(%r{^#{context.root_path}/?(.*?)#{sprockets_extnames_regexp}}, '\1')

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

      process_requires(compiler.requires, context)
      process_required_trees(compiler.required_trees, context)

      if Opal::Config.source_map_enabled
        map_contents = compiler.source_map.as_json.to_json
        ::Opal::SourceMapServer.set_map_cache(sprockets, logical_path, map_contents)
      end

      result.to_s
    end

    def self.sprockets_extnames_regexp(sprockets)
      joined_extnames = sprockets.engines.keys.map { |ext| Regexp.escape(ext) }.join('|')
      Regexp.new("(#{joined_extnames})*\z")
    end

    def sprockets_extnames_regexp
      @sprockets_extnames_regexp ||= self.class.sprockets_extnames_regexp(@sprockets)
    end

    def process_requires(requires, context)
      requires.each do |required|
        required = required.sub(sprockets_extnames_regexp, '')
        context.require_asset required unless stubbed_files.include? required
      end
    end

    # Mimics (v2) Sprockets::DirectiveProcessor#process_require_tree_directive
    def process_required_trees(required_trees, context)
      return if required_trees.empty?

      # This is the root dir of the logical path, we need this because
      # the compiler gives us the path relative to the file's logical path.
      dirname = File.dirname(file).gsub(/#{Regexp.escape File.dirname(context.logical_path)}\z/, '')
      dirname = Pathname(dirname)

      required_trees.each do |original_required_tree|
        required_tree = Pathname(original_required_tree)

        unless required_tree.relative?
          raise ArgumentError, "require_tree argument must be a relative path: #{required_tree.inspect}"
        end

        required_tree = dirname.join(file, '..', required_tree)

        unless required_tree.directory?
          raise ArgumentError, "require_tree argument must be a directory: #{[original_required_tree, required_tree].inspect}"
        end

        context.depend_on required_tree.to_s

        environment = context.environment

        if environment.respond_to?(:each_entry)
          # Sprockets 2
          environment.each_entry(required_tree) do |pathname|
            if pathname.to_s == file
              next
            elsif pathname.directory?
              context.depend_on(pathname)
            elsif context.asset_requirable?(pathname)
              context.require_asset(pathname)
            end
          end
        else
          # Sprockets 3
          processor = ::Sprockets::DirectiveProcessor.new
          processor.instance_variable_set('@dirname', File.dirname(file))
          processor.instance_variable_set('@environment', environment)
          path = processor.__send__(:expand_relative_dirname, :require_tree, original_required_tree)
          absolute_paths = environment.__send__(:stat_sorted_tree_with_dependencies, path).first.map(&:first)

          absolute_paths.each do |path|
            path = Pathname(path)
            pathname = path.relative_path_from(dirname)

            if name.to_s == file
              next
            elsif path.directory?
              context.depend_on(path.to_s)
            else
              context.require_asset(pathname)
            end
          end
        end
      end
    end

    def self.load_asset_code(sprockets, name)
      asset = sprockets[name.sub(/(\.(js|rb|opal))*\z/, '.js')]
      return '' if asset.nil?

      opal_extnames = sprockets.engines.map do |ext, engine|
        ext if engine <= ::Opal::Processor
      end.compact

      module_name = -> asset { asset.logical_path.sub(/\.js\z/, '') }
      path_extnames = -> path { File.basename(path).scan(/\.[^.]+/) }
      mark_as_loaded = -> path { "Opal.mark_as_loaded(#{path.inspect});" }
      processed_by_opal = -> asset { (path_extnames[asset.pathname] & opal_extnames).any? }

      non_opal_assets = ([asset]+asset.dependencies)
        .select { |asset| not(processed_by_opal[asset]) }
        .map { |asset| module_name[asset] }

      mark_as_loaded = (['opal'] + non_opal_assets + stubbed_files.to_a)
        .map { |path| mark_as_loaded[path] }

      if processed_by_opal[asset]
        load_asset_code = "Opal.load(#{module_name[asset].inspect});"
      end

      <<-JS
      if (typeof(Opal) !== 'undefined') {
        #{mark_as_loaded.join("\n")}
        #{load_asset_code}
      }
      JS
    end

    def self.stubbed_files
      @stubbed_files ||= Set.new
    end

    def self.stub_file(name)
      stubbed_files << name.to_s
    end

    def stubbed_files
      self.class.stubbed_files
    end
  end
end

Sprockets.register_engine '.rb',  Opal::Processor
Sprockets.register_engine '.opal',  Opal::Processor
