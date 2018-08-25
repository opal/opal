# frozen_string_literal: true

module Opal
  # To generate the source map for a single file use Opal::SourceMap::File.
  # To combine multiple files the Opal::SourceMap::Index should be used.
  module SourceMap
    autoload :Map,   'opal/source_map/map'
    autoload :File,  'opal/source_map/file'
    autoload :Index, 'opal/source_map/index'
    autoload :VLQ,   'opal/source_map/vlq'
  end
end
