# frozen_string_literal: true

require 'opal/paths'

# The compiler runner will just output the compiled JavaScript
class Opal::CliRunners::Compiler
  def self.call(data)
    new(data).start
  end

  def initialize(data)
    @options         = data[:options] || {}
    @builder_factory = data.fetch(:builder)
    @map_file        = @options[:map_file]
    @output          = data.fetch(:output)
    @watch           = @options[:watch]
  end

  def compile
    builder = @builder_factory.call
    compiled_source = builder.to_s
    compiled_source += "\n" + builder.source_map.to_data_uri_comment unless @options[:no_source_map]

    rewind_output if @watch

    @output.puts compiled_source
    @output.flush

    File.write(@map_file, builder.source_map.to_json) if @map_file

    builder
  end

  def compile_noraise
    compile
  rescue StandardError, Opal::SyntaxError => e
    $stderr.puts "* Compilation failed: #{e.message}"
    nil
  end

  def rewind_output
    if !@output.is_a?(File) || @output.tty?
      fail_unrewindable!
    else
      begin
        @output.rewind
        @output.truncate(0)
      rescue Errno::ESPIPE
        fail_unrewindable!
      end
    end
  end

  def fail_unrewindable!
    abort <<~ERROR
      You have specified --watch, but for watch to work, you must specify an
      --output file.
    ERROR
  end

  def fail_no_listen!
    abort <<~ERROR
      --watch mode requires the `listen` gem present. Please try to run:

          gem install listen

      Or if you are using bundler, add listen to your Gemfile.
    ERROR
  end

  def watch_compile
    begin
      require 'listen'
    rescue LoadError
      fail_no_listen!
    end

    @opal_deps = Opal.dependent_files

    builder = compile
    code_deps = builder.dependent_files
    @files = @opal_deps + code_deps
    @code_listener = watch_files
    @code_listener.start

    $stderr.puts "* Opal v#{Opal::VERSION} successfully compiled your program in --watch mode"

    sleep
  rescue Interrupt
    $stderr.puts '* Stopping watcher...'
    @code_listener.stop
  end

  def reexec
    Process.kill('USR2', Process.pid)
  end

  def on_code_change(modified)
    if !(modified & @opal_deps).empty?
      $stderr.puts "* Modified core Opal files: #{modified.join(', ')}; reexecuting"
      reexec
    elsif !modified.all? { |file| @directories.any? { |dir| file.start_with?(dir + '/') } }
      $stderr.puts "* New unwatched files: #{modified.join(', ')}; reexecuting"
      reexec
    end

    $stderr.puts "* Modified code: #{modified.join(', ')}; rebuilding"

    builder = compile_noraise

    # Ignore the bad compilation
    if builder
      code_deps = builder.dependent_files
      @files = @opal_deps + code_deps
    end
  end

  def files_to_directories
    directories = @files.map { |file| File.dirname(file) }.uniq

    previous_dir = nil
    # Only get the topmost directories
    directories = directories.sort.map do |dir|
      if previous_dir && dir.start_with?(previous_dir + '/')
        nil
      else
        previous_dir = dir
      end
    end

    directories.compact
  end

  def watch_files
    @directories = files_to_directories

    Listen.to(*@directories, ignore!: []) do |modified, added, removed|
      our_modified = @files & (modified + added + removed)
      on_code_change(our_modified) unless our_modified.empty?
    end
  end

  def start
    if @watch
      watch_compile
    else
      compile
    end

    0
  end
end
