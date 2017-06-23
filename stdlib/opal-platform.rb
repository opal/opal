browser         = `typeof(document) !== "undefined"`
node            = `typeof(process) !== "undefined" && process.versions && process.versions.node`
nashorn         = `typeof(Java) !== "undefined" && Java.type`
headless_chrome = `typeof(navigator) !== "undefined" && /\bHeadlessChrome\//.test(navigator.userAgent)`

case
when nashorn
  OPAL_PLATFORM = 'nashorn'
when node
  OPAL_PLATFORM = 'nodejs'
when headless_chrome
  OPAL_PLATFORM = 'headless-chrome'
else # possibly browser, which is the primary target
  OPAL_PLATFORM = nil
end
