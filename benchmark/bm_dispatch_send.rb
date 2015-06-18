class SendDispatch
  attr_reader :event_log

  def initialize
    @event_log = []
  end

  def call(event)
    handler_name = "handle_#{event.name}"
    __send__(handler_name, event) if respond_to?(handler_name)
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

klass = SendDispatch
event = Struct.new(:name, :source, :args)

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
