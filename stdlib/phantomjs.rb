`Opal.exit = function(status) { callPhantom(['exit', status]); };`
STDOUT.write_proc = `function(str){callPhantom(['stdout', str])}`
STDERR.write_proc = `function(str){callPhantom(['stderr', str])}`
