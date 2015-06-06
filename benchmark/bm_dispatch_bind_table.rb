class BindTableDispatch
  attr_reader :event_log

  def initialize
    @event_log = []
  end

  def self.method_added_cheat(method_name)
    if method_name.to_s =~ /^handle_(.+)$/
      handler_methods[$1.to_sym] = instance_method(method_name)
    end
    # Cheating here, because Opal does not support method_added hook yet
    # Uncomment the super below when it does:
    # super
  end

  def self.handler_methods
    @handler_methods ||= {}
  end

  def call(event)
    if (handler_method = self.class.handler_methods[event.name])
      handler_method.bind(self).call(event)
    end
  end

  def handle_foo(event)
    event_log << event
  end

  def handle_bar(event)
    event_log << event
  end

  def handle_baz(event)
    event_log << event
  end
end

klass = BindTableDispatch
event = Struct.new(:name, :source, :args)

# Cheating here, because Opal does not support method_added hook yet
klass.method_added_cheat(:handle_foo)
klass.method_added_cheat(:handle_bar)
klass.method_added_cheat(:handle_baz)

100_000.times do
  obj = klass.new
  obj.call(e1 = event[:foo])
  obj.call(e2 = event[:bar])
  obj.call(e3 = event[:baz])
  obj.call(event[:buz])
  unless obj.event_log == [e1, e2, e3]
    raise "#{klass}: #{obj.event_log.inspect}"
  end
end
