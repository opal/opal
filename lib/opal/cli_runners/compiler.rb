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
    @directory       = @options[:directory]
  end

  def compile(builder = nil)
    builder ||= @builder_factory.call

    if @directory
      builder.compile_to_directory(@output, with_source_map: !@options[:no_source_map])
    else
      compiled_source = builder.compiled_source(with_source_map: !@options[:no_source_map])

      rewind_output if @watch

      @output.puts compiled_source
      @output.flush

      File.write(@map_file, builder.source_map.to_json) if @map_file
    end

    builder
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
    @opal_deps = Opal.dependent_files

    builder = compile
    code_deps = builder.dependent_files
    @files = @opal_deps + code_deps

    $stderr.puts "* Opal v#{Opal::VERSION} successfully compiled your program in --watch mode"

    builder.watch do |bldr, changes|
      unless changes.key?(:error)
        modified = changes[:added].map(&:abs_path) + changes[:modified].map(&:abs_path) + changes[:removed].map(&:abs_path)
        on_code_change(bldr, modified)
      end
    end
  end

  def reexec
    Process.kill('USR2', Process.pid)
  end

  def on_code_change(builder, modified)
    if !(modified & @opal_deps).empty?
      $stderr.puts "* Modified core Opal files: #{modified.join(', ')}; reexecuting"
      reexec
    elsif !modified.all? { |file| @directories.any? { |dir| file.start_with?(dir + '/') } }
      $stderr.puts "* New unwatched files: #{modified.join(', ')}; reexecuting"
      reexec
    end
    $stderr.puts '* Modified code rebuilding'

    compile(builder)

    # Ignore the bad compilation
    code_deps = builder.dependent_files
    @files = @opal_deps + code_deps
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

  def start
    if @watch
      watch_compile
    else
      compile
    end

    0
  end
end
