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


