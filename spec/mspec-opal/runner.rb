require 'mspec-opal/formatters'

class OSpecFilter
  def self.main
    @main ||= self.new
  end

  def initialize
    @filters = Set.new
    @seen = Set.new
  end

  def register
    if ENV['INVERT_RUNNING_MODE']
      MSpec.register :include, self
    else
      MSpec.register :exclude, self
    end
  end

  def ===(description)
    @seen << description
    @filters.include?(description)
  end

  def register_filters(description, block)
    instance_eval(&block)
  end

  def fails(description)
    @filters << description
  end

  def fails_badly(description)
    if ENV['INVERT_RUNNING_MODE']
      warn "WARNING: FAILS BADLY: Ignoring filter to avoid blocking the suite: #{description.inspect}"
    else
      @filters << description
    end
  end

  def unused_filters_message(list: false)
    unused = @filters - @seen
    return if unused.size == 0

    if list
      puts
      puts "Unused filters:"
      unused.each {|u| puts "  fails #{u.inspect}"}
      puts
    else
      warn "\nThere are #{unused.size} unused filters, re-run with ENV['LIST_UNUSED_FILTERS'] = true to list them\n\n"
    end
  end
end

class Object
  def opal_filter(description, &block)
    OSpecFilter.main.register_filters(description, block)
  end

  alias opal_unsupported_filter opal_filter
end

# MSpec relies on File.readable? to do method detection on backtraces
class File
  def self.readable?(path)
    false
  end
end

class OSpecFormatter
  def self.main
    @main ||= self.new
  end

  def default_formatter
    formatters = {
      'browser'      => BrowserFormatter,
      'server'       => BrowserFormatter,
      'chrome'       => DottedFormatter,
      'node'         => NodeJSFormatter,
      'nodejs'       => NodeJSFormatter,
      'gjs'          => ColoredDottedFormatter,
      'quickjs'      => ColoredDottedFormatter,
      'nodedoc'      => NodeJSDocFormatter,
      'nodejsdoc'    => NodeJSDocFormatter,
      'dotted'       => DottedFormatter
    }

    formatter = formatters.fetch(ENV['FORMATTER']) do
      warn "Using the default 'dotted' formatter, set the FORMATTER env var to select a different formatter (was: #{ENV['FORMATTER'].inspect}, options: #{formatters.keys.join(", ")})"
      DottedFormatter
    end

    if ENV['INVERT_RUNNING_MODE']
      formatter = Class.new(formatter)
      formatter.include InvertedFormatter
    end

    formatter
  end

  def register(formatter_class = default_formatter)
    formatter_class.new.register
  end
end

class OpalBM
  def self.main
    @main ||= self.new
  end

  def register(repeat, bm_filepath)
    `self.bm = {}`
    `self.bm_filepath = bm_filepath`
    MSpec.repeat = repeat
    MSpec.register :before, self
    MSpec.register :after,  self
    MSpec.register :finish, self
  end

  def before(state = nil)
    %x{
      if (self.bm && !self.bm.hasOwnProperty(state.description)) {
        self.bm[state.description] = {started: Date.now()};
      }
    }
  end

  def after(state = nil)
    %x{
      if (self.bm) {
        self.bm[state.description].stopped = Date.now();
      }
    }
  end

  def finish
    %x{
      var obj = self.bm, key, val, report = '';
      if (obj) {
        for (key in obj) {
          if (obj.hasOwnProperty(key)) {
            val = obj[key];
            report += key.replace(/\s/g, '_') + ' ' + ((val.stopped - val.started) / 1000) + '\n';
          }
        }
        require('fs').writeFileSync(self.bm_filepath, report);
      }
    }
  end
end

module OutputSilencer
  def silence_stdout
    original_stdout = $stdout
    new_stdout = IO.new(1, 'w')
    new_stdout.write_proc = ->s{}

    begin
      $stdout = new_stdout
      yield
    ensure
      $stdout = original_stdout
    end
  end
end

OSpecFormatter.main.register
OSpecFilter.main.register

MSpec.enable_feature :encoding
