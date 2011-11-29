module Opal
  class GitDependency
    attr_reader :name
    attr_reader :url

    def initialize(name, url, path)
      @name = name
      @url  = url
      @path = path
    end

    def inspect
      "<#{self.class} name=#{@name.inspect} url=#{@url.inspect}>"
    end

    alias_method :to_s, :inspect

    def install
      raise "Dependency already installed: #{@name}" if installed?

      FileUtils.mkdir_p File.dirname(@path)
      system "git clone --quiet #{@url} #{@path}"
    end

    # Returns `true` if the dependency has been properly installed to
    # the given path, `false` otherwise.
    #
    # @return [true, false]
    def installed?
      File.exists?(@path)
    end

    # Returns the [Bundle] instance for this dependency.
    #
    # @return [Bundle]
    def bundle
      @bundle ||= Bundle.new(@path)
    end
  end
end

