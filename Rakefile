$:.unshift File.expand_path(File.join('..', 'opal_lib'), __FILE__)
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

desc "Build opal.parser.js which is just the parser tools - requires opal.js to run"
task :opal_parser do
  FileUtils.mkdir_p 'extras'
  File.open('extras/opal.parser.js', 'w+') do |out|
    out.write opal_copyright
    out.write Opal::Builder.new.build_parser
  end
end

desc "Opal runtime + parser combined for in browser testing of opal"
task :opal_dev do
  FileUtils.mkdir_p 'extras'
  File.open('extras/opal.dev.js', 'w+') do |out|
    builder = Opal::Builder.new
    out.write opal_copyright
    out.write builder.build_core
    out.write builder.build_parser
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

require 'yard'

YARD::Rake::YardocTask.new do |t|
  t.files   = ['lib/**/*.rb']
  t.options = ['--title', 'Documentation for Opal Core Library',
              '--markup', 'markdown']
end

desc "Rebuild ruby_parser.rb for opal build tools"
task :parser do
  %x{racc -l opal_lib/opal/ruby/ruby_parser.y -o opal_lib/opal/ruby/ruby_parser.rb}
end


