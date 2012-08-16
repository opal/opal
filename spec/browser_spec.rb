require 'spec_helper'
require 'v8'

class OpalRuntimeSpecCollector
  def initialize
    ctx = V8::Context.new

    %w(opal opal-parser opal-spec specs).each do |f|
      path = File.join Opal::opal_dir, 'build', "#{f}.js"
      ctx.eval File.read(path), path
    end

    ctx['console'] = self
    ctx['spec_collector'] = self

    ctx.eval Opal.parse('Spec::Runner.new.run')
  end

  def log(*s)
    puts *s
  end

  def example_group_started(group_name)
    @group_name = group_name
    @passed     = []
    @failed     = []
  end

  def example_group_finished(group_name)
    passed = @passed
    failed = @failed

    Kernel.describe(@group_name) do
      passed.each do |p|
        it(p) {}
      end

      failed.each do |f|
        it(f[0]) { raise f[1] }
      end
    end
  end

  def example_passed(description)
    @passed << description
  end

  def example_failed(description, message)
    @failed << [description, message]
  end
end

# Run all browser specs inside v8 and build rspec groups from them
OpalRuntimeSpecCollector.new