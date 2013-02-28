module OSpec
  class Group
    def self.stack
      @stack ||= []
    end

    def self.create(desc, block)
      parent = Group.stack.last

      Class.new(parent || Group) do
        @desc = desc
        @parent = parent
      end
    end

    def self.groups
      @groups ||= []
    end

    def self.inherited(klass)
      Group.groups << klass
      klass.instance_eval do
        @before_hooks = []
        @after_hooks = []
        @examples = []
        @pending = []
      end
    end

    def self.to_s
      "<OSpec::Group #{description.inspect}>"
    end

    def self.description
      @parent ? "#{@parent.description} #{@desc}" : @desc
    end

    def self.it(desc, &block)
      @examples << [desc, block]
    end

    def self.pending(desc, &block)
      @pending << [desc, block]
    end

    # type is ignored (is always :each)
    def self.before(type = nil, &block)
      @before_hooks << block
    end

    # type is ignored (is always :each)
    def self.after(type = nil, &block)
      @after_hooks << block
    end

    def self.before_hooks
      @parent ? [].concat(@parent.before_hooks).concat(@before_hooks) : @before_hooks
    end

    def self.after_hooks
      @parent ? [].concat(@parent.after_hooks).concat(@after_hooks) : @after_hooks
    end

    def self.run(runner)
      @runner = runner
      @runner.example_group_started self

      @examples.each do |example|
        instance = self.new example[0], example[1]
        instance.run @runner
      end

      @runner.example_group_finished self
    end

    # Specs marked as a ruby_bug. We let them all through
    def self.ruby_bug(*args, &block)
      block.call
    end

    # Spec behaves like a shared group. Ignore for now
    def self.it_behaves_like(*args)
    end

    attr_reader :example_group, :exception

    def initialize(name, block)
      @__name__ = name
      @__block__ = block
      @example_group = self.class
    end

    def description
      @__name__
    end

    def run(runner)
      @__runner__ = runner
      begin
        @__runner__.example_started self
        run_before_hooks
        instance_eval(&@__block__)
      rescue => e
        @exception = e
      ensure
        run_after_hooks
      end

      finish_running
    end

    def finish_running
      if @exception
        @__runner__.example_failed self
      else
        @__runner__.example_passed self
      end
    end

    def run_after_hooks
      begin
        @example_group.after_hooks.each do |after|
          instance_eval &after
        end
      rescue => e
        @exception = e
      end
    end

    def run_before_hooks
      @example_group.before_hooks.each do |before|
        instance_eval &before
      end
    end
  end
end
