# frozen_string_literal: true

require 'opal/paths'

# The compiler runner will just output the compiled JavaScript
Opal::CliRunners::Compiler = ->(data) {
  options  = data[:options] || {}
  builder  = data.fetch(:builder)
  map_file = options[:map_file]
  output   = data.fetch(:output)

  compiled_source = builder.to_s
  compiled_source += "\n" + builder.source_map.to_data_uri_comment unless options[:no_source_map]
  output.puts compiled_source
  File.write(map_file, builder.source_map.to_json) if map_file

  0
}
