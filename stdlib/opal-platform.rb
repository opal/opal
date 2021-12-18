`/* global Java, GjsFileImporter */`

browser          = `typeof(document) !== "undefined"`
node             = `typeof(process) !== "undefined" && process.versions && process.versions.node`
nashorn          = `typeof(Java) !== "undefined" && Java.type`
headless_browser = `(typeof(navigator) !== "undefined" && navigator.webdriver) || typeof(OpalHeadless) !== "undefined"`
gjs              = `typeof(window) !== "undefined" && typeof(GjsFileImporter) !== 'undefined'`
quickjs          = `typeof(window) === "undefined" && typeof(__loadScript) !== 'undefined'`
opal_miniracer   = `typeof(opalminiracer) !== 'undefined'`

OPAL_PLATFORM = if nashorn
                  'nashorn'
                elsif node
                  'nodejs'
                elsif headless_browser
                  'headless-browser'
                elsif gjs
                  'gjs'
                elsif quickjs
                  'quickjs'
                elsif opal_miniracer
                  'opal-miniracer'
                else # possibly browser, which is the primary target
                end
