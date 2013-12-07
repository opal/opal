require 'sprockets'
require 'sprockets/base'

module Sprockets
  class Base
    def cache_key_for(path, options)
      "#{path}:#{options[:bundle] ? '1' : '0'}"
      processors = attributes_for(path).processors
      processors_key = processors.map do |p|
        version = p.respond_to?(:version) ? p.version : '0'
        "#{p.name}-#{version}"
      end.join(':')

      "#{path}:#{options[:bundle] ? '1' : '0'}:#{processors_key}"
    end
  end
end
