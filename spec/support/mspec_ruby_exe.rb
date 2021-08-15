require 'mspec/helpers/ruby_exe'
require 'nodejs/file'
require 'buffer'

def ruby_exe_options(option)
  'bin/opal -rcorelib/pattern_matching'
end

def ruby_exe(code = :not_given, opts = {})
  if opts[:dir]
    raise "ruby_exe(..., dir: dir) is no longer supported, use Dir.chdir"
  end

  if code == :not_given
    return RUBY_EXE.split(' ')
  end

  env = opts[:env] || {}
  saved_env = {}
  env.each do |key, value|
    key = key.to_s
    saved_env[key] = ENV[key] if ENV.key? key
    ENV[key] = value
  end

  escape = opts.delete(:escape)
  if code and !File.exist?(code) and escape != false
    # Patch:
    #tmpfile = tmp("rubyexe.rb")
    tmpfile = "/tmp/rubyexe.rb"
    File.open(tmpfile, "w") { |f| f.write(code) }
    code = tmpfile
  end

  expected_exit_status = opts.fetch(:exit_status, 0)

  begin
    #platform_is_not :opal do
      command = ruby_cmd(code, opts)
      # Patch:
      #output = `#{command}`
      output = self.`(command)

      last_status = Process.last_status
      if last_status.exitstatus != expected_exit_status
        raise "Expected exit status is #{expected_exit_status.inspect} but actual is #{last_status.exitstatus.inspect} for command ruby_exe(#{command.inspect})"
      end

      output
    #end
  ensure
    saved_env.each { |key, value| ENV[key] = value }
    env.keys.each do |key|
      key = key.to_s
      ENV.delete key unless saved_env.key? key
    end
    File.delete tmpfile if tmpfile
  end
end