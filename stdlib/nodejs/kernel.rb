`Opal.exit = process.exit`

module Kernel
  NODE_REQUIRE = `require`

  @__child_process__ = `require('child_process')`
  `var __child_process__ = #{@__child_process__}`

  # @deprecated Please use `require('module')` instead
  def node_require(path)
    warn '[DEPRECATION] node_require is deprecated. Please use `require(\'module\')` instead.'
    `#{NODE_REQUIRE}(#{path.to_str})`
  end

  def system(cmdname, *argv, exception: false)
    out = if argv.empty?
      `__child_process__.spawnSync(#{cmdname}, { shell: true, stdio: 'inherit' })`
    elsif Array === cmdname
      `__child_process__.spawnSync(#{cmdname}, #{argv}, { stdio: 'inherit' })`
    else
      `__child_process__.spawnSync(#{cmdname[0]}, #{argv}, { argv0: #{cmdname[1]}, stdio: 'inherit' })`
    end

    $? = `#{out}.status`
    raise "Command failed with exit #{$?}: #{cmdname}" if exception && $? != 0
    $? == 0
  end

  def `(cmdline)
    Buffer.new(`__child_process__.execSync(#{cmdline})`).to_s.encode('UTF-8')
  end
end

ARGV = `process.argv.slice(2)`
