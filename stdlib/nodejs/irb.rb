require 'native'

NodeRepl = Native(`OpalNode.node_require('repl')`)

def NodeRepl.start opations = {}
  Native::Object.new(`#@native.start(#{opations.to_n})`)
end

line = 1
prompt_interrupted = false

prompt = ->(_self) {
  tip = prompt_interrupted ? '*' : '>'
  "irb(#{_self.to_s}):#{line.to_s.rjust(3, '0')}#{tip} "
}

$repl = NodeRepl.start prompt: prompt.call(self),
                       useGlobal: true, ignoreUndefined: true,
                       eval: -> (cmd, context, filename, callback) {
  line += 1

  cmd = cmd[1...-1].chomp

  if cmd.empty?
    prompt_interrupted = true
    $repl.prompt = prompt.call(self)

    callback.call('')
    next
  end

  prompt_interrupted = false
  $repl.prompt = prompt.call(self)

  begin
    result = `OpalNode.run(cmd, filename)`
    result = nil if `#{result} == nil`
    callback.call('=> '+result.inspect)
  rescue => e
    callback.call(e.backtrace.join("\n"))
  end
}

# Add a newline before exiting
$repl.on :exit, -> { puts }
