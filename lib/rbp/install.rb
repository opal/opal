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
      FileUtils.mkdir_p 'vendor'

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
      end
    end

  end
end

