`console.log('loaded phantomjs');`
module Kernel
  def exit status = 0
    `callPhantom(['exit', status]);`
  end
end

STDOUT.write_proc = `function(str){callPhantom(['stdout', str])}`
STDERR.write_proc = `function(str){callPhantom(['stderr', str])}`
