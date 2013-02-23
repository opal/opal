# A base namespace for template libraries to register their templates. This
# file is not loaded by opal directly, so a templating library would need to
# require this file itself (e.g. opal-erb.rb requires it, so each erb template)
# doesn't need to do it itself.
#
#     # foo.erb
#     ERB.new('foo') do
#       # template body
#     end
#
#     # inside opal-erb.rb
#     class ERB
#       def initialize(name, &block)
#         @block = block
#         Template[name] = self
#       end
#
#       # standard method for templates
#       def render(ctx)
#         #...
#       end
#     end
#
module Template
  @_cache = {}
  def self.[](name)
    @_cache[name]
  end

  def self.[]=(name, instance)
    @_cache[name] = instance
  end  
end
