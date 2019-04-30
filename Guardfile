require 'guard/plugin'

class ::Guard::Opal < Plugin
  def mspec *paths
    command = ['bundle', 'exec', './bin/opal-mspec', *paths.flatten]
    result = time(:mspec, *paths) { system *command }
    notify 'MSpec', result
  end

  def rspec *paths
    command = ['bundle', 'exec', 'rspec', *paths.flatten]
    result = time(:rspec, *paths) { system *command }
    notify 'RSpec', result
  end

  def notify lib, result
    if result
      ::Guard::Notifier.notify(
        'Success ♥︎', title: "#{lib} results", image: :success, priority: 1
      )
    else
      ::Guard::Notifier.notify(
        'Failed ♠︎', title: "#{lib} results", image: :failed, priority: 1
      )
    end
  end

  def color *args
    Guard::UI.send :color, *args
  end

  def terminal_columns
    cols = `tput cols 2> /dev/tty`.strip.to_i
    ($?.success? && cols.nonzero?) ? cols : 80
  end

  def time *titles
    columns = terminal_columns
    puts color("=== running: #{titles.join(' ')} ".ljust(columns,'='), :cyan)
    s = Time.now
    result = yield
    t = (Time.now - s).to_f
    puts color("=== time: #{t} seconds ".ljust(columns, '='), :cyan)
    result
  end

  def run_on_changes(changes)
    m = changes
    path = m[0]
    puts color("Searching specs for #{m[0]}...", :yellow)
    case path
    when %r{^spec/lib}     then rspec path
    when %r{^spec/ruby} then mspec path
    when %r{^opal/corelib}
      name = File.basename(path, '.rb')
      mspec "spec/ruby/core/#{name}/**/*_spec.rb"
    when %r{^lib/opal/(.*)\.rb$}
      name = $1
      specs = Dir["spec/lib/#{name}_spec.rb"]
      rspec *specs
    end
  end

  def run_all
    time(:all) { system 'bundle', 'exec', 'rake' }
  end
end

guard :opal do
  ignore %r{^(tmp|tasks|pkg|cdn|build|node_modules|grammar.rb)}
  watch %r{^spec/.*}
  watch %r{^lib/.*}
  watch %r{^bin/.*}
  watch %r{^opal/.*}
  watch %r{^stdlib/.*}
end
