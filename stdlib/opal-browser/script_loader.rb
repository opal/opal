class BrowserScriptLoader
  def run
    handler = proc { find_scripts }

    if $global.respond_to? :addEventListener
      $global.addEventListener 'DOMContentLoaded', handler, false
    elsif @global.respond_to? :attachEvent
      $global.attachEvent 'onload', handler
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
    $global.document.getElementsByTagName('script').to_a.select { |s|
      s.type == "text/ruby" }
  end

  def run_ruby str
    $global.Opal.eval str
  end
end

if $global.respond_to? :document
  BrowserScriptLoader.new.run
end

