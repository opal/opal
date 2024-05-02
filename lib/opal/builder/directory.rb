# frozen_string_literal: true

module Opal
  class Builder

    class DirectoryFile
      attr_reader :file, :module_name, :compiled_filename, :source_map_filename, :source_filename, :index_js, :index_mjs, :index_html, :file_name

      def initialize(file, output_extension:, source_prefix: 'opal/src', version_prefix: "opal/#{Opal::VERSION_MAJOR_MINOR}")
        @file = file
        @output_extension = output_extension
        @module_name = Compiler.module_name(file.filename)
        @compiled_filename = "#{version_prefix}/#{module_name}.#{output_extension}",
        @source_map_filename = "#{version_prefix}/#{module_name}.map",
        @source_filename = "#{source_prefix}/#{Pathname(filename).cleanpath.to_s}",
        @index_js = "index.js",
        @index_mjs = "index.mjs",
        @index_html = "index.html",
        @file_name = Pathname(file.filename).cleanpath.to_s
      end

      def compiled_source(with_source_map: true)
        compiled_source = @file.to_s
        compiled_source += "\n//# sourceMappingURL=./#{File.basename(@module_name)}.map" if with_source_map
        compiled_source
      end

      # Correct the map to point to source files and remove embedded source
      def map_contents
        depth = module_name.split('/').length - 1

        source_map = @file.source_map.to_h.dup
        source_map[:sourceRoot] = "./#{'../' * depth}../../#{source_prefix}"
        source_map[:sources] = [file_name]
        source_map.delete(:sourcesContent)
        source_map.to_json
      end
    end

    class IndexFile
      attr_reader :index

      def initialize(module_names = [], output_extension:, version_prefix: "opal/#{Opal::VERSION_MAJOR_MINOR}")
        @module_names = module_names
        @output_extension = output_extension
        @index = module_names.map { |i| "./#{version_prefix}/#{i}.#{output_extension}" }
      end

      def <<(module_name)
        return if @module_names.include?(module_name)

        @module_names << module_name
        @index << "./#{version_prefix}/#{module_name}.#{output_extension}"
      end

      def requires_contents
        index.map { |i| "require(#{i.to_json});" }.join("\n") + "\n"
      end

      def import_contents
        index.map { |i| "import #{i.to_json};" }.join("\n") + "\n"
      end

      def html_contents
        <<~HTML
          <!doctype html>
          <html>
          <head>
            <meta charset='utf-8'>
            <title>Opal application</title>
          </head>
          <body>
            #{index.map { |i| "<script type='module' src='#{i}'></script>" }.join("\n  ")}
          </body>
          </html>
        HTML
      end
    end


    # This module is included into Builder, provides abstracted data about a new
    # paradigm of compiling Opal applications into a directory.
    module Directory
      def version_prefix
        "opal/#{Opal::VERSION_MAJOR_MINOR}"
      end

      def source_prefix
        'opal/src'
      end

      # Output method #compile_to_directory depends on a directory compiler
      # option being set, so that imports are generated correctly.
      def compile_to_directory(dir = nil, single_file: nil, with_source_map: true)
        raise ArgumentError, 'no directory provided' if dir.nil? && single_file.nil?

        index = IndexFile.new([], output_extension: output_extension)

        processed.each do |file|
          # skip if single_file is set and the file is not the one we want
          next if single_file && !paths[file.filename].keys.include?(single_file)

          directory_file = DirectoryFile.new(file)
          index << directory_file.module_name if file.options[:load] || !file.options[:requirable]

          if !single_file
            write_file(dir, directory_file.compiled_filename, directory_file.compiled_source(with_source_map:))
            if with_source_map
              write_file(dir, directory_file.source_map_filename, directory_file.map_contents)
              write_file(dir, directory_file.source_filename, file.original_source)
            end
          else
            return directory_file.compiled_source(with_source_map:) if single_file == directory_file.compiled_filename
            if with_source_map
              return directory_file.map_contents if single_file == directory_file.source_map_filename(index)
              return file.original_source if single_file == directory_file.source_filename
            end
          end
        end

        if esm?
          write_file(dir, 'index.mjs', index.import_contents)
          write_file(dir, 'index.html', index.html_contents)
        else
          write_file(dir, 'index.js', index.requires_contents)
        end

        if esm?
          return index.import_contents
          return index.html_contents
        else
          return index.requires_contents
        end
      end

      private

      def write_file(dir, file, content)
        FileUtils.mkdir_p(File.dirname("#{dir}/#{file}"))
        File.binwrite("#{dir}/#{file}", content)
      end
    end
  end
end
