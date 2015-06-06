class HardcodedDispatch
  attr_reader :event_log

  def initialize
    @event_log = []
  end

  def call(event)
    case event.name
    when :foo
      handle_foo(event)
    when :bar
      handle_bar(event)
    when :baz
      handle_baz(event)
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

klass = HardcodedDispatch
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
