$:.unshift File.expand_path(File.join('..', 'opalite'), __FILE__)
require 'opal'
require 'fileutils'

opal_copyright = <<-EOS
/*!
 * Opal v0.3.2
 * http://opalscript.org
 *
 * Copyright 2011, Adam Beynon
 * Released under the MIT license
 */
EOS

desc "Build extras/opal.js ready for browser runtime"
task :opal do
  FileUtils.mkdir_p 'extras'
  File.open('extras/opal.js', 'w+') do |out|
    out.write opal_copyright
    out.write Opal::Builder.new.build_core
  end
end

desc "Build extras/opal_dev.js ready for in browser parser"
task :opal_dev do
  FileUtils.mkdir_p 'extras'
  File.open('extras/opal_dev.js', 'w+') do |out|
    builder = Opal::Builder.new
    out.write opal_copyright
    out.write "(function() {"
    %w[dev dev/ruby_parser dev/nodes dev/string_scanner dev/parser].each do |src|
      out.write File.read("lib/#{src}.js")
    end
    out.write "})();"
  end
end

task :dev do
  FileUtils.mkdir_p 'extras'
  File.open('extras/opal.parser.js', 'w+') do |out|
    builder = Opal::Builder.new
    %w[opal/ruby/nodes opal/ruby/parser opal/ruby/ruby_parser].each do |src|
      full = File.join(File.dirname(__FILE__), 'opalite', src + '.rb')
      code = builder.compile_source full
      out.write "opal.register('#{src}.js', #{code})"
    end
  end
end

desc "Build ospec package into extras/opal.spec.js ready for browser tests"
task :opal_spec do
  FileUtils.mkdir_p 'extras'
  File.open('extras/opal.spec.js', 'w+') do |out|
    builder = Opal::Builder.new
    out.write opal_copyright
    out.write builder.build_core
    out.write builder.build_stdlib 'ospec.rb', 'ospec/**/*.rb'

    Dir['spec/**/*.rb'].each do |spec|
      out.write builder.wrap_source(spec, spec)
    end

    out.write "opal.require('ospec/autorun')"
  end

  File.open('extras/opal.spec.html', 'w+') do |out|
    out.write <<-HTML
<!DOCTYPE html>
<html>
  <head>
    <title>Opal specs</title>
    <script type="text/javascript" src="opal.spec.js"></script>
  </head>
  <body></body>
</html>
HTML
  end
end

opal_dev_copyright = <<-EOS
/*!
 * OpalParser - Ruby parser, written in Javascript, for opal.
 * http://opalscript.org
 *
 * Copyright 2011, Adam Beynon
 * Released under the MIT license.
 */
EOS

desc "Rebuild js parser using racc2js"
task :js_parser do
  require File.join(File.dirname(__FILE__), 'tools', 'racc2js', 'racc2js.rb')

  class OpalDevParser < Racc2JS

    # overide post code specificallt for opal
    def post
      %Q[\n    return parser;
        })();

        opal.dev.#@parser_name = #@parser_name;
      ]
    end
  end

  parser = OpalDevParser.new File.join(File.dirname(__FILE__), 'lib', 'opal_parser', 'ruby_parser.y')
  parser.generate
end

require 'yard'

YARD::Rake::YardocTask.new do |t|
  t.files   = ['lib/**/*.rb']
  t.options = ['--title', 'Documentation for Opal Core Library',
              '--markup', 'markdown']
end

desc "Rebuild ruby_parser.rb for opal build tools"
task :parser do
  %x{racc -l opalite/opal/ruby/ruby_parser.y -o opalite/opal/ruby/ruby_parser.rb}
end


