require 'opal/nodes/call'

class Opal::Nodes::CallNode
  # Rubyspec uses this call to load in language specific features at runtime.
  # We can't do this at runtime, so handle it during compilation
  add_special :language_version do
    if scope.top?
      lang_type = arglist.children[1].children[0]
      target = "ruby/language/versions/#{lang_type}_1.9"

      if File.exist?(target)
        compiler.requires << target
      end

      push fragment("nil")
    end
  end

  add_special :not_supported_on do
    unless arglist.children.include?(s(:sym, :opal))
      compile_default!
    end
  end

  add_special :not_compliant_on do
    unless arglist.children.include?(s(:sym, :opal))
      compile_default!
    end
  end

  add_special :platform_is_not do
    unless arglist.children.include?(s(:sym, :opal))
      compile_default!
    end
  end

  add_special :platform_is do
    if arglist.children.include?(s(:sym, :opal))
      compile_default!
    end
  end

  add_special :requirable_spec_file do
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

Dir[File.expand_path('../../../spec/filters/unsupported/**/*.rb', __FILE__)].each { |f| require f }
Dir[File.expand_path('../../../spec/filters/bugs/**/*.rb', __FILE__)].each { |f| require f }
