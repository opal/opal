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

  def unused_filters_message(list: false)
    unused = @filters - @seen
    return if unused.size == 0

    if list
      puts
      puts "Unused filters:"
      unused.each {|u| puts "- #{u}".gsub("\n", "\\n")}
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

  # Copyed from MSpec, with changes.
  def with_timezone(name, offset = nil, daylight_saving_zone = "")
    zone = name.dup

    if offset
      # TZ convention is backwards
      offset = -offset

      zone += offset.to_s
      zone += ":00:00"
    end
    zone += daylight_saving_zone

    # WAS:
    #
    #   old = ENV["TZ"]
    #   ENV["TZ"] = zone
    #
    #   begin
    #     yield
    #   ensure
    #     ENV["TZ"] = old
    #   end
    #
    if ENV["TZ"] == zone
      yield
    else
      1.should == 1 # MSpec will get mad if the example has no expectations.
      warn "Skipped spec for TZ=#{zone} as it's not supported"
    end
  end
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
    return InvertedFormatter if ENV['INVERT_RUNNING_MODE']

    # Uncomment one of the following to use a different formatter:
    #
    # BrowserFormatter
    # NodeJSFormatter
    # NodeJSDocFormatter
    # PhantomFormatter
    # PhantomDocFormatter
    DottedFormatter
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
    new_stdout = IO.new
    new_stdout.extend IO::Writable
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
