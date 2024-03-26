# backtick_javascript: true

require 'buffer'
require 'corelib/process/status'

module Kernel
  @__child_process__ = Opal::Raw.import('node:child_process')
  @__cluster__ = Opal::Raw.import('node:cluster')
  @__process__ = Opal::Raw.import('node:process')
  `var __child_process__ = #{@__child_process__}`
  `var __cluster__ = #{@__cluster__}`
  `var __process__ = #{@__process__}`

  def system(*argv, exception: false)
    env = {}
    env = argv.shift if argv.first.is_a? Hash
    env = ENV.merge(env).to_n
    cmdname = argv.shift

    out = if argv.empty?
            `__child_process__.spawnSync(#{cmdname}, { shell: true, stdio: 'inherit', env: #{env} })`
          elsif Array === cmdname
            `__child_process__.spawnSync(#{cmdname[0]}, #{argv}, { argv0: #{cmdname[1]}, stdio: 'inherit', env: #{env} })`
          else
            `__child_process__.spawnSync(#{cmdname}, #{argv}, { stdio: 'inherit', env: #{env} })`
          end

    status = out.JS[:status]
    status = 127 if `status === null`
    pid = out.JS[:pid]

    $? = Process::Status.new(status, pid)
    raise "Command failed with exit #{status}: #{cmdname}" if exception && status != 0
    status == 0
  end

  def `(cmdline)
    Buffer.new(`__child_process__.execSync(#{cmdline})`).to_s.encode('UTF-8')
  end

  def fork
    `var worker`
    if block_given?
      %x{
        if (__cluster__.isPrimary) {
          worker = __cluster__.fork();
          return worker.process.pid;
        } else if (__cluster__.isWorker) {
          #{yield}
        }
      }
    else
      %x{
        if (__cluster__.isPrimary) {
          worker = __cluster__.fork();
          return worker.process.pid;
        }
      }
    end
  end
end
