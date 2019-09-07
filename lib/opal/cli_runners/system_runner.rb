# frozen_string_literal: true

require 'tempfile'

# Generic runner that will resort to calling an external program.
#
# @option :options [Hash,nil] :env a hash of options to be used as env in the
#   call to system.
# @option :options [true,false] :debug enabling debug mode will write the
#   compiled JavaScript file in the current working directory.
# @yield tempfile [File] Gives a file to the block, its #path can be used to
#   construct the command
# @yieldreturn command [Array<String>] the command to be used in the system call
SystemRunner = ->(data, &block) {
  options  = data[:options] || {}
  builder  = data.fetch(:builder)
  output   = data.fetch(:output)

  env      = options.fetch(:env, {})
  debug    = options.fetch(:debug, false)

  code = builder.to_s + "\n" + builder.source_map.to_data_uri_comment

  tempfile =
    if debug
      File.new('opal-nodejs-runner.js', 'w')
    else
      Tempfile.new('opal-system-runner-')
    end

  tempfile.write code
  cmd = block.call tempfile
  tempfile.close

  # JRuby (v9.2) doesn't support using `out:` to redirect output.
  if IO.try_convert(output) && RUBY_PLATFORM != 'java'
    system(env, *cmd, out: output)
    $?.exitstatus
  else
    require 'open3'
    captured_output, status = Open3.capture2(env, *cmd)
    output.write captured_output
    status.exitstatus
  end
}
