# frozen_string_literal: true

module Opal
  class Builder
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

        catch(:file) do
          index = []

          processed.each do |file|
            module_name = Compiler.module_name(file.filename)
            last_segment_name = File.basename(module_name)
            depth = module_name.split('/').length - 1
            file_name = Pathname(file.filename).cleanpath.to_s
            setup_project(file.abs_path)

            index << module_name if file.options[:load] || !file.options[:requirable]

            compiled_filename = "#{version_prefix}/#{module_name}.#{output_extension}"
            try_building_single_file(dir, compiled_filename, single_file) do
              compiled_source = file.to_s
              compiled_source += "\n//# sourceMappingURL=./#{last_segment_name}.map" if with_source_map
              compiled_source
            end

            if with_source_map
              source_map_filename = "#{version_prefix}/#{module_name}.map"
              try_building_single_file(dir, source_map_filename, single_file) do
                # Correct the map to point to source files and remove embedded source
                source_map = file.source_map.to_h.dup
                source_map[:sourceRoot] = "./#{'../' * depth}../../#{source_prefix}"
                source_map[:sources] = [file_name]
                source_map.delete(:sourcesContent)
                source_map.to_json
              end

              source_filename = "#{source_prefix}/#{file_name}"
              try_building_single_file(dir, source_filename, single_file) do
                file.original_source
              end
            end
          end

          compile_index(dir, index: index, single_file: single_file)
          compile_npm(dir, single_file: single_file)
        end
      end

      private

      # Generates executable index files
      def compile_index(dir = nil, index:, single_file: nil)
        index = index.map { |i| "./#{version_prefix}/#{i}.#{output_extension}" }

        if !esm?
          try_building_single_file(dir, 'index.js', single_file) do
            index.map { |i| "require(#{i.to_json});" }.join("\n") + "\n"
          end
        else
          try_building_single_file(dir, 'index.mjs', single_file) do
            index.map { |i| "import #{i.to_json};" }.join("\n") + "\n"
          end

          try_building_single_file(dir, 'index.html', single_file) do
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
      end

      # Generates package.json and runs `npm i` afterwards
      def compile_npm(dir, _project = nil, single_file: nil)
        try_building_single_file(dir, 'package.json', single_file) do
          npm = {}
          npm[:private] = true
          npm[:dependencies] = {}
          npm[:type] = esm? ? 'module' : 'commonjs'
          npm[:main] = "./index.#{output_extension}"

          # npm_dependencies.each do |name, version|
          #   npm[:dependencies][name] = version
          # end

          JSON.dump(npm)
        end

        # unless npm_dependencies.empty?
        #   system(*OS.bash_c("pushd #{OS.shellescape dir}",
        #                     'npm i',
        #                     'popd'
        #                   )
        #         )
        # end
      end

      # A helper method to either generate a single file or write a file to
      # a specified location.
      def try_building_single_file(dir, file, single_file, &_block)
        if !single_file
          FileUtils.mkdir_p(File.dirname("#{dir}/#{file}"))
          File.binwrite("#{dir}/#{file}", yield)
        elsif single_file == file
          throw :file, yield
        end
      end
    end
  end
end
