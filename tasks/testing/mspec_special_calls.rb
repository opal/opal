require 'opal/nodes/call'
require 'opal/ast/builder'

class Opal::Nodes::CallNode
  # Rubyspec uses these calls features at runtime.
  # We can't do this at runtime, so handle it during compilation

  add_special :not_supported_on do |compile_default|
    unless arglist.children.include?(s(:sym, :opal))
      compile_default.call
    end
  end

  add_special :requirable_spec_file do |compile_default|
    str = DependencyResolver.new(compiler, arglist.children[0]).resolve
    compiler.track_require str unless str.nil?
  end
end

require 'opal/rewriter'
require 'opal/rewriters/rubyspec/filters_rewriter'

Opal::Rewriter.use Opal::Rubyspec::FiltersRewriter

# When a spec is marked as filtered (most probably non-implemented functionality)
# we need to exclude it from the test suite
# (except of the case with inverted suite specified using INVERT_RUNNING_MODE=true)
#
def opal_filter(filter_name, &block)
  unless ENV['INVERT_RUNNING_MODE']
    Opal::Rubyspec::FiltersRewriter.instance_eval(&block)
  end
end

# When a spec is marked as unsupported we need to exclude it from the test suite.
#
# This filter ignores ENV['INVERT_RUNNING_MODE'],
# unsupported feature is always unsupported.
#
def opal_unsupported_filter(filter_name, &block)
  Opal::Rubyspec::FiltersRewriter.instance_eval(&block)
end

Dir[File.expand_path('../../../spec/filters/unsupported/**/*.rb', __FILE__)].each { |f| require f }
Dir[File.expand_path('../../../spec/filters/bugs/**/*.rb', __FILE__)].each { |f| require f }
