# A simple event registering/triggering module to mix into classes.
# Events are stored in the `@events` ivar.
module Eventable

  # Register a handler for the given event name.
  #
  #   obj.on(:foo) { puts "foo was called" }
  #
  # @param [String, Symbol] name event name
  def on(name, &handler)
    @events ||= Hash.new { |hash, key| hash[key] = [] }
    @events[name] << handler
  end

  # Trigger the given event name and passes all args to each handler
  # for this event.
  #
  #   obj.trigger(:foo)
  #   obj.trigger(:foo, 1, 2, 3)
  #
  # @param [String, Symbol] name event name to trigger
  def trigger(name, *args)
    @events ||= Hash.new { |hash, key| hash[key] = [] }
    @events[name].each { |handler| handler.call(*args) }
  end
end
