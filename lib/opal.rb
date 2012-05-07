require 'opal/parser/parser'
require 'opal/builder'
require 'opal/dependency_builder'
require 'opal/context'
require 'opal/version'

module Opal
  # Base Opal directory - used by build tools
  # @return [String]
  def self.opal_dir
    File.expand_path '../..', __FILE__
  end

  # Returns a string of javascript code for the opal runtime in normal
  # mode.
  # @return [String]
  def self.runtime_code
    path = File.join opal_dir, 'opal.js'
    return File.read path if File.exists? path

    build_runtime false
  end

  # Debug mode code for opal runtime
  # @return [String]
  def self.runtime_debug_code
    path = File.join opal_dir, 'opal.debug.js'
    return File.read path if File.exists? path

    build_runtime true
  end

  # Builds the runtime in normal mode by default.
  #
  # @param [Boolean] debug whether to build in debug mode (or not)
  # @return [String] string of javascript code
  def self.build_runtime(debug = false)
    code = []
    code << HEADER
    code << '(function(undefined) {'
    code << kernel_source(debug)
    code << method_names
    code << corelib_source(debug)
    code << '}).call(this);'

    code.join "\n"
  end

  # Returns the source ruby code for the corelib as a string. Corelib is
  # always parsed as one large file.
  # @return [String]
  def self.corelib_source(debug = false)
    order  = File.read(File.join(opal_dir, 'core/load_order')).strip.split
    parser = Opal::Parser.new :debug => debug

    source = order.map { |c| File.read File.join(opal_dir, "core/#{c}.rb") }.join("\n")
    #"(#{parser.parse source, '(corelib)'}).call(opal.top, opal);"
    parser.parse source, '(corelib)'
  end

  # Returns javascript source for the kernel/runtime of opal.
  # @return [String]
  def self.kernel_source(debug = false)
    order = %w[runtime]
    order.map { |c| File.read File.join(opal_dir, "core/#{c}.js") }.join("\n")
  end

  # Get all special method names from the parser and generate js code that
  # is passed into runtime. This saves having special names duplicated in
  # runtime AND parser.
  # @return [String]
  def self.method_names
    methods = Opal::Parser::METHOD_NAMES.map { |f, t| "'#{f}': '$#{t}$'" }
    %Q{
      var method_names = {#{ methods.join ', ' }};
      var reverse_method_names = {};
      for (var id in method_names) {
        reverse_method_names[method_names[id]] = id;
      }
    }
  end

  # Header used in generated runtime code
  HEADER = <<-HEADER
/*!
 * opal v#{VERSION}
 * http://opalrb.org
 *
 * Copyright 2012, Adam Beynon
 * Released under the MIT license
 */
  HEADER
end
