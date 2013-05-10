class BrowserScriptLoader
  def run
    handler = proc { find_scripts }

    if $window.respond_to? :addEventListener
      $window.addEventListener 'DOMContentLoaded', handler, false
    else
      $window.attachEvent 'onload', handler
    end
  end

  def find_scripts
    ruby_scripts.each do |script|
      if src = script.src and src != ""
        puts "Cannot currently load remote script: #{src}"
      else
        run_ruby script.innerHTML
      end
    end
  end

  def ruby_scripts
    $document.getElementsByTagName('script').to_a.select { |s|
      s.type == "text/ruby" }
  end

  def run_ruby str
    $window.Opal.eval str
  end
end

if $window and $document
  BrowserScriptLoader.new.run
end

