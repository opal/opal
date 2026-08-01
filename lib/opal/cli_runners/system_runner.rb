# frozen_string_literal: true

require 'tmpdir'
require 'fileutils'

module Opal
  VirtualFileObject = Struct.new(:path, keyword_init: true)

  # Generic runner that will resort to calling an external program.
  #
  # @option :options [Hash,nil] :env a hash of options to be used as env in the
  #   call to system.
  # @option :options [true,false] :debug enabling debug mode will write the
  #   compiled JavaScript file in the current working directory.
  # @yield tempfile [File] Gives a file to the block, its #path can be used to
  #   construct the command
  # @yieldreturn command [Array<String>] the command to be used in the system call
  SystemRunner = ->(data, &block) do
    options  = data[:options] || {}
    builder  = data.fetch(:builder).call
    output   = data.fetch(:output)

    env      = options.fetch(:env, {})
    debug    = options.fetch(:debug, false) || RUBY_ENGINE == 'opal'

    ext = builder.output_extension

    if options[:directory]
      tempdir = Dir.mktmpdir('opal-system-runner-')
      builder.compile_to_directory(tempdir, with_source_map: !options[:no_source_map])
      cmd = block.call(
        VirtualFileObject.new(path: File.join(tempdir, "index.#{ext}"))
      )
    else
      # Temporary issue with UTF-8, Base64, source maps and opalopal
      code = builder.compiled_source(
        with_source_map: !(options[:no_source_map] || RUBY_ENGINE == 'opal')
      )

      file_name = if debug
                    "opal-system-runner.#{ext}"
                  else
                    Dir::Tmpname.create('opal-system-runner') { |t| "#{t}.#{ext}" }
                  end
      tempfile = File.new(file_name, 'wb')

      tempfile.write code
      cmd = block.call tempfile
    end

    if RUBY_PLATFORM == 'opal'
      # Opal doesn't support neither `out:` nor `IO.try_convert` nor `open3`
      system(env, *cmd)
      $?.exitstatus
    elsif IO.try_convert(output)
      system(env, *cmd, out: output)
      $?.exitstatus
    else
      require 'open3'
      captured_output, status = Open3.capture2(env, *cmd)
      output.write captured_output
      status.exitstatus
    end
  ensure
    tempfile.close if tempfile
    FileUtils.remove_entry(tempdir) if tempdir && !debug
  end
end
