require 'opal'
require 'tilt/template'
require 'tilt'

module Tilt
  # Opal templates do not support object scopes, locals, or yield.
  class OpalTemplate < ::Tilt::Template
    self.default_mime_type = 'application/javascript'

    @@default_bare = false

    def self.default_bare
      @@default_bare
    end

    def self.default_bare=(value)
      @@default_bare = value
    end

    def self.engine_initialized?
      defined? ::Opal
    end

    def initialize_engine
      require_template_library 'opal'
    end
    
    def prepare
    end

    def self.opal_core
      @opal_core ||= Opal::Builder.new.build_core
    end

    # def builder_evaluate
    #   # require 'stringio'
    #   # out = StringIO.new
    #   # 
    #   # opts = options
    #   # builder = Opal::Builder.new
    #   # builder.build :files => path,
    #   #   :out => opts["out"], :watch => opts["watch"], :main => opts["main"]
    #   # 
    #   # 
    #   # # build
    #   # files = options[:files] || []
    #   # files = [files] unless files.is_a? Array
    #   # options[:files] = files = Dir.[](*files)
    #   # 
    #   # raise "Opal::Builder - No input files could be found" if files.empty?
    #   # 
    #   # main = options[:main]
    #   # 
    #   # if main == true
    #   #   options[:main] = files.first
    #   # elsif main
    #   #   raise "Opal::Builder - Main file does not exist!" unless File.exists? main
    #   #   files << main unless files.include? main
    #   # elsif main == false
    #   #   options[:main] = false
    #   # else
    #   #   options[:main] = files.first
    #   # end
    #   # 
    #   # main = options[:main]
    #   # 
    #   # unless options[:out]
    #   #   options[:out] = main.sub /\.rb$/, '.js'
    #   # end
    #   # 
    #   # FileUtils.mkdir_p File.dirname(options[:out])
    #   # 
    #   # rebuild options
    #   # 
    #   # 
    #   # 
    #   # # rebuild
    #   # 
    #   # puts "rebuilding to #{options[:out]}"
    #   # puts options[:files].inspect
    #   # File.open(options[:out], 'w') do |out|
    #   #   # out.write @pre if @pre
    #   # 
    #   #   options[:files].each do |file|
    #   #     out.write wrap_source file
    #   #   end
    #   # 
    #   #   if options[:main]
    #   #     main = options[:main].sub(/\.rb$/, '')
    #   #     out.write "opal.require('#{main}');\n"
    #   #   end
    #   # 
    #   #   # out.write @post if @post
    #   # end
    #   # 
    #   # 
    # end

    def evaluate(scope, locals, &block)
      return @output if defined? @output
      
      js_src = Opal::RubyParser.new(data).parse!.generate_top
      @output = <<-OPAL
        opal.register('try.rb', function($rb, self, __FILE__) {
          #{js_src}
        });
        opal.require('try');
      OPAL
    end
  end
  
  register OpalTemplate, '.opal'
end
