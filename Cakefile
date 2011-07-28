{spawn, exec} = require 'child_process'

runCommand = (name, args...) ->
  proc = spawn name, args
  proc.stderr.on 'data', (buffer) -> console.log buffer.toString()
  proc.stdout.on 'data', (buffer) -> console.log buffer.toString()
  proc.on        'exit', (status) -> process.exit(1) if status isnt 0

task 'assets:watch', 'Watch coffee filesand build JS source', (opts) ->

  runCommand 'coffee', '-wc', 'src'

task 'assets:build', 'Build JS source files', (opts) ->

  runCommand 'coffee', '-wc', 'src'
