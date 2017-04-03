phantomjs = `typeof(callPhantom) !== "undefined"`
browser   = `typeof(document) !== "undefined"`
node      = `typeof(process) !== "undefined" && process.versions && process.versions.node`
nashorn   = `typeof(Java) !== "undefined" && Java.type`

case
when nashorn
  OPAL_PLATFORM = 'nashorn'
when phantomjs
  OPAL_PLATFORM = 'phantomjs'
when node
  OPAL_PLATFORM = 'nodejs'
else # possibly browser, which is the primary target
  OPAL_PLATFORM = nil
end
