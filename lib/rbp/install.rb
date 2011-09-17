module RBP

  # Install dependencies
  class Install

    def initialize
      @package = Package.new
    end

    ##
    # Run installer - for now just installs all packages in local
    # package.yml into vendor/

    def install
      bootstrap true

      deps = @package.dependencies

      deps.each do |dep|
        unless Hash === dep and dep.keys.length == 1
          raise "Bad dependency format"
        end

        name = dep.keys[0]
        git  = dep.values[0]
        target = File.expand_path File.join("vendor", name)

        # only install git urls for now..
        if /^git\:\/\// !~ git
          puts "Skipping `#{name}' (non git url)"
          next

        elsif File.exist? target
          puts "Skipping `#{name}' (already exists)"
          next
        end

        puts "Installing `#{name}'"
        system "git clone #{git} #{target}"
        add_package_lib name
      end
    end

    ##
    # Bootstrap rbp system. This basically checks if the vendor
    # directory exists and setup.rb can be found in it. If so, we stop.
    # If it doesnt then we create them. If force is true then we delete
    # the vendor directory and start from scratch.

    def bootstrap(force = false)
      FileUtils.rm_rf 'vendor' if force and File.exists? 'vendor'

      return if File.exists? 'vendor/setup.rb'

      # vendor directory
      FileUtils.mkdir 'vendor'

      # basic setup.rb file
      File.open('vendor/setup.rb', 'w+') do |o|
        o.puts "# root packages' path"
        o.puts "path = File.expand_path('..', __FILE__)"
        o.puts
        o.puts "# root packages' lib directory"
        o.puts "$:.unshift File.expand_path(\"\#{path}/../lib\")"
        o.puts
      end
    end

    ##
    # Add the package with the given name to setup.rb. We can assume we
    # have already downloaded/copied the gem locally into that dir

    def add_package_lib(name)
      code = "$:.unshift File.expand_path(\"\#{path}/../vendor/#{name}/lib\")\n"

      out = "vendor/setup.rb"
      read = File.read(out)

      File.open(out, 'w+') { |o| o.write(read + code) }
    end

  end
end

