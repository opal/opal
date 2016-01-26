`Opal.exit = function(status) { callPhantom(['exit', status]); };`

STDOUT.write_proc = `function(str){callPhantom(['stdout', str])}`
STDERR.write_proc = `function(str){callPhantom(['stderr', str])}`

STDOUT.tty = true
STDERR.tty = true

ARGV += `JSON.parse(callPhantom(['argv']))`

%x{
  var env = JSON.parse(callPhantom(['env']));

  Object.keys(env).forEach(function(key) {
    #{ENV[`key`] = `env[key]`}
  });
}
