require 'opal/parser'

module Opal
  class Builder
    def self.corelib
      base = Opal.core_dir
      src = File.read(File.join base, 'opal.rb')
      result = []

      src.scan(/\#=\ require\ '(.*)'/).each do |m|
        path = File.join base, "#{m.first}.rb"

        if File.exist? path
          result << Opal.parse(File.read path)
        else
          result << File.read(File.join base, "#{m.first}.js")
        end
      end

      result << Opal.parse(src)

      result.join
    end
  end
end
