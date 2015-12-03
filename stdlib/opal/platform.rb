phantomjs = `typeof(callPhantom) !== "undefined"`
browser   = `typeof(document) !== "undefined"`
node      = `typeof(process) !== "undefined" && process.versions && process.versions.node`

case
when phantomjs
  OPAL_PLATFORM = 'phantomjs'
  require 'phantomjs'
when node
  OPAL_PLATFORM = 'nodejs'
  require 'nodejs/kernel'
  require 'nodejs/io'
else # browser, which is the primary target
  # noop
end
