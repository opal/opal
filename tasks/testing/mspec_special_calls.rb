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

  add_special :not_compliant_on do |compile_default|
    unless arglist.children.include?(s(:sym, :opal))
      compile_default.call
    end
  end

  has_xstring = -> node {
    next if node.nil? || !node.respond_to?(:type)
    node.type == :xstr || (node.children && node.children.any?(&has_xstring))
  }

  add_special :platform_is_not do |compile_default|
    next if arglist.children.include?(s(:sym, :opal))
    next if children.any?(&has_xstring)

    compile_default.call
  end

  add_special :platform_is do |compile_default|
    if arglist.children.include?(s(:sym, :opal)) || !children.any?(&has_xstring)
      compile_default.call
    end
  end

  add_special :requirable_spec_file do |compile_default|
    str = DependencyResolver.new(compiler, arglist.children[0]).resolve
    compiler.requires << str unless str.nil?
  end
end

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

# In the test environment we have to parse invalid characters
# Otherwise the parser throws an error and the whole suites aborts
class Opal::AST::Builder
  def string_value(token)
    unless token[0].valid_encoding?
      diagnostic(:warning, :invalid_encoding, nil, token[1])
    end

    token[0]
  end
end

Dir[File.expand_path('../../../spec/filters/unsupported/**/*.rb', __FILE__)].each { |f| require f }
Dir[File.expand_path('../../../spec/filters/bugs/**/*.rb', __FILE__)].each { |f| require f }
