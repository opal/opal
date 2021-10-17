`/* global Java, GjsFileImporter */`

browser         = `typeof(document) !== "undefined"`
node            = `typeof(process) !== "undefined" && process.versions && process.versions.node`
nashorn         = `typeof(Java) !== "undefined" && Java.type`
headless_chrome = `typeof(navigator) !== "undefined" && /\bHeadlessChrome\//.test(navigator.userAgent)`
gjs             = `typeof(window) !== "undefined" && typeof(GjsFileImporter) !== 'undefined'`
windows_wscript = `typeof(window) !== "undefined" && typeof(WScript) !== 'undefined'`
opal_miniracer  = `typeof(opalminiracer) !== 'undefined'`

OPAL_PLATFORM = if nashorn
                  'nashorn'
                elsif node
                  'nodejs'
                elsif headless_chrome
                  'headless-chrome'
                elsif gjs
                  'gjs'
                elsif windows_wscript
                  'wscript'
                elsif opal_miniracer
                  'opal-miniracer'
                else # possibly browser, which is the primary target
                end
