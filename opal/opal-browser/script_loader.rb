class BrowserScriptLoader
  def initialize
    @doc = Native.global.document
    @win = Native.global
  end

  def run
    handler = proc { find_scripts }

    if @win.key? :addEventListener
      @win.addEventListener 'DOMContentLoaded', handler, false
    else
      @win.attachEvent 'onload', handler
    end
  end

  def find_scripts
    ruby_scripts.each do |script|
      if src = script.src and src != ""
        puts "Cannot currently load script src: #{src}"
      else
        run_ruby script.innerHTML
      end
    end
  end

  def ruby_scripts
    all = @doc.getElementsByTagName 'script' 
    all.to_a.select { |s| s.type == "text/ruby" }
  end

  def run_ruby str
    Native.global.Opal.eval str
  end
end

if Native.global.key? :window and  Native.global.key? :document
  BrowserScriptLoader.new.run
end

