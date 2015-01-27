require 'opal/nodes'

class Opal::Nodes::CallNode
  # Rubyspec uses this call to load in language specific features at runtime.
  # We can't do this at runtime, so handle it during compilation
  add_special :language_version do
    if scope.top?
      lang_type = arglist[2][1]
      target = "corelib/language/versions/#{lang_type}_1.9"

      if File.exist?(target)
        compiler.requires << target
      end

      push fragment("nil")
    end
  end

  add_special :not_supported_on do
    unless arglist.flatten.include? :opal
      compile_default!
    end
  end

  add_special :platform_is_not do
    unless arglist.flatten.include? :opal
      compile_default!
    end
  end

  add_special :platform_is do
    if arglist.flatten.include? :opal
      compile_default!
    end
  end
end


