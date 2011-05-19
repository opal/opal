require 'ospec/runner/options'
require 'ospec/runner/reporter'
require 'ospec/runner/example_group_runner'

require 'ospec/runner/formatter/html_formatter'
require 'ospec/runner/formatter/terminal_formatter'

module Spec
  module Runner
  
    def self.run
      options.run_examples
    end
  
    def self.options
      @options ||= Options.new
      @options
    end

    # Autorun for the browser. This differs from {.autorun} because it wraps
    # itself in a setTimeout call to make sure the browser is ready as we
    # start adding to the DOM as we run. This won't use rquery because its
    # nice to keep everything independant, and someone might write a better
    # DOM library. All the dom interactions are simply inline javascript.
    def self.autorun_browser
      `setTimeout(function() {`
        specs = Dir["spec/**/*.{rb,js}"]

        if specs.length == 0
          puts "ospec: no input files given"
        else
          if File.exist? "spec/spec_helper.js"
            require File.expand_path("spec/spec_helper.js")
          end

          specs.each do |spec|
            require spec
          end
          # require specs[0]
          # idx = 49
          # puts idx
          # `console.log(specs[idx]);`
          # puts specs[idx]
          # puts specs[idx]
          # require specs[idx]
        end

        Spec::Runner.run
        puts Spec::Runner.options.formatters
      `}, 0);`
      nil
    end
    
    # Autorun gem/node context
    def self.autorun
      puts "in here"
      puts ARGV.inspect
      if ARGV.length == 0
        specs = Dir["spec/**/*.{rb,js}"]

        if specs.length == 0
          puts "ospec: no input files given"
        else

          if File.exist? "spec/spec_helper.rb"
            require File.expand_path "spec/spec_helper.rb"
          end

          specs.each do |spec|
            require spec
          end
        end
        # return
      end

      ARGV.each do |spec|
        puts "should try and load #{spec}"
        if File.exist? spec
          puts "loading: " + File.expand_path(spec)
          require File.expand_path(spec)
        else
          raise "Bad spec to load (does not exist): #{spec}"
        end
      end

      Spec::Runner.run
    end

  end # Runner
end
