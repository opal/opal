require 'json'

require 'source_map/vlq.rb'
require 'source_map/generator.rb'
require 'source_map/parser.rb'

class SourceMap
  include SourceMap::Generator
  include SourceMap::Parser

  # Create a new blank SourceMap
  #
  # Options may include:
  #
  # :file => String           # See {#file}
  # :source_root => String    # See {#source_root}
  # :generated_output => IO   # See {#generated_output}
  #
  # :sources => Array[String] # See {#sources}
  # :names => Array[String]   # See {#names}
  #
  # :version => 3             # Which version of SourceMap to use (only 3 is allowed)
  #
  def initialize(opts={})
    unless (remain = opts.keys - [:generated_output, :file, :source_root, :sources, :names, :version]).empty?
      raise ArgumentError, "Unsupported options to SourceMap.new: #{remain.inspect}"
    end
    self.generated_output = opts[:generated_output]
    self.file = opts[:file] || ''
    self.source_root = opts[:source_root] || ''
    self.version = opts[:version] || 3
    self.sources = opts[:sources] || []
    self.names = opts[:names] || []
    self.mappings = []
    raise "version #{opts[:version]} not supported" if version != 3
  end

  # The name of the file containing the code that this SourceMap describes.
  # (default "")
  attr_accessor :file

  # The URL/directory that contains the original source files.
  #
  # This is prefixed to the entries in ['sources']
  # (default "")
  attr_accessor :source_root

  # The version of the SourceMap spec we're using.
  # (default 3)
  attr_accessor :version

  # The list of sources (used during parsing/generating)
  # These are relative to the source_root.
  # (default [])
  attr_accessor :sources

  # A list of names (used during parsing/generating)
  # (default [])
  attr_accessor :names

  # A list of mapping objects.
  attr_accessor :mappings
end
