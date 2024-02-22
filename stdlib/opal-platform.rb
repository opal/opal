# backtick_javascript: true

`/* global Java, GjsFileImporter, Deno, Bun */`

browser          = `typeof(document) !== "undefined"`
bun              = `typeof(Bun) === "object" && typeof(Bun.version) === "string"`
deno             = `typeof(Deno) === "object" && typeof(Deno.version) === "object"`
node             = `typeof(process) !== "undefined" && process.versions && process.versions.node`
nashorn          = `typeof(Java) !== "undefined" && Java.type`
headless_chrome  = `typeof(opalheadlesschrome) !== "undefined"`
headless_firefox = `typeof(opalheadlessfirefox) !== "undefined"`
safari           = `typeof(opalsafari) !== "undefined"`
gjs              = `typeof(window) !== "undefined" && typeof(GjsFileImporter) !== "undefined"`
quickjs          = `typeof(window) === "undefined" && typeof(__loadScript) !== "undefined"`
opal_miniracer   = `typeof(opalminiracer) !== "undefined"`

OPAL_PLATFORM = if nashorn
                  'nashorn'
                elsif bun
                  'bun'
                elsif deno
                  'deno'
                elsif node
                  'nodejs'
                elsif headless_chrome
                  'headless-chrome'
                elsif headless_firefox
                  'headless-firefox'
                elsif safari
                  'safari'
                elsif gjs
                  'gjs'
                elsif quickjs
                  'quickjs'
                elsif opal_miniracer
                  'opal-miniracer'
                else # possibly browser, which is the primary target
                end
