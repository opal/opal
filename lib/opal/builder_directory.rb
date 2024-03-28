# frozen_string_literal: true

require 'fileutils'
require 'json'
require 'opal/os'

module Opal
  # This module is included into Builder, provides abstracted data about a new
  # paradigm of compiling Opal applications into a directory.
  module BuilderDirectory
    def version_prefix
      "opal/#{Opal::VERSION.split(".").first(2).join(".")}"
    end

    def source_prefix
      "opal/src"
    end

    # Output method #compile_to_directory depends on a directory compiler
    # option being set, so that imports are generated correctly.
    def compile_to_directory(dir, with_source_map: true)
      index = []
      npm_dependencies = []

      processed.each do |file|
        module_name = Compiler.module_name(file.filename)
        last_segment_name = File.basename(module_name)
        depth = module_name.split("/").length - 1

        project = setup_project(file.abs_path)

        compiled_source = file.to_s

        if with_source_map
          file_name = Pathname(file.filename).cleanpath.to_s

          # Correct the map to point to source files
          source_map = file.source_map.to_h.dup
          source_map[:sourceRoot] = "./"+"../"*depth+"../../"+source_prefix
          source_map[:sources] = [file_name]
          source_map.delete(:sourcesContent)
          source_map = source_map.to_json

          compiled_source += "\n//# sourceMappingURL=./#{last_segment_name}.map" if with_source_map
        end

        compiled_filename = "#{dir}/#{version_prefix}/#{module_name}.#{output_extension}"
        FileUtils.mkdir_p(File.dirname(compiled_filename))
        File.binwrite(compiled_filename, compiled_source)
        
        if with_source_map
          source_map_filename = "#{dir}/#{version_prefix}/#{module_name}.map"
          File.binwrite(source_map_filename, source_map)

          source_filename = "#{dir}/#{source_prefix}/#{file_name}"
          FileUtils.mkdir_p(File.dirname(source_filename))
          File.binwrite(source_filename, file.source)
        end

        index << module_name if file.options[:load] || !file.options[:requirable]

        npm_dependencies += file.npm_dependencies if file.respond_to? :npm_dependencies
      end

      compile_index(dir, index)
      compile_npm(dir, npm_dependencies)
    end

    # Generates executable index files
    def compile_index(dir, index)
      index = index.map { |i| "./#{version_prefix}/#{i}.#{output_extension}" }

      if !esm?
        File.binwrite("#{dir}/index.js", index.map { |i| "require(#{i.to_json});" }.join("\n") + "\n")
      else
        File.binwrite("#{dir}/index.mjs", index.map { |i| "import #{i.to_json};" }.join("\n") + "\n")

        html = <<~HTML
          <!doctype html>
          <html>
          <head>
            <meta charset='utf-8'>
            <title>Opal application</title>
          </head>
          <body>
            #{if esm?
                index.map { |i| "<script type='module' src='#{i}'></script>" }.join("\n  ")
              else
                index.map { |i| "<script src='#{i}'></script>" }.join("\n  ")
              end}
          </body>
          </html>
        HTML

        File.binwrite("#{dir}/index.html", html)
      end
    end

    # Generates package.json and runs `npm i` afterwards
    def compile_npm(dir, npm_dependencies)
      npm = {}
      npm[:private] = true
      npm[:dependencies] = {}
      npm[:type] = esm? ? 'module' : 'commonjs'
      npm[:main] = "./index.#{output_extension}"

      npm_dependencies.each do |name, version|
        npm[:dependencies][name] = version
      end

      File.binwrite("#{dir}/package.json", JSON.dump(npm))

      unless npm_dependencies.empty?
        system(*OS.bash_c("pushd #{OS.shellescape dir}",
                          'npm i',
                          'popd'
                         )
              )
      end
    end
  end
end
