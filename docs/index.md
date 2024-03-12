# Opal Guides for v1.6.dev

These guides are designed to make you immediately productive with Opal, and to help you understand how all of the pieces fit together.

The guides for earlier releases are [available here](/docs).

---

## Start here

#### [Getting Started with Opal](getting_started.html)

Everything you need to know to install Opal and create your first application.

---

## Using JavaScript Features from Ruby

#### [Interfacing with JavaScript](js_interface.html)

Discover how to access JavaScript environment from Ruby code.

#### [Async](async.html)

Learn more about JavaScript `async`/`await` support in Opal and how you can use it to avoid explicit callbacks and promises.

#### [Promises](promises.html)

How to interact and leverage the power of JavaScript promises from Ruby.

#### [Source Maps](source_maps.html)

How to enable and consume source-maps for your Opal application and be able to debug your Ruby scripts right inside the browser.

---

## Using Ruby Features

#### [Working with ERB and Haml Templates](templates.html)

How to work with template libraries in Opal, be it to share the templates with the server or to write your own.

---

## Working with Frameworks

#### [Rails](rails.html)

How to use `opal-rails` to use Opal as the JavaScript compiler.

#### [Static Applications](static_applications.html)

The most basic setup for a static Opal powered website that can be hosted anywhere.

#### [Sinatra](sinatra.html)

Serve Opal applications through Sinatra and `opal-sprockets`.

#### [Roda + Sprockets](roda-sprockets.html)

Setup Roda + Sprockets to start serving Opal applications from Roda.

---

## Interacting with Other Libraries

#### [jQuery](jquery.html)

This guide covers the `opal-jquery` wrapper around the popular library.

#### [RSpec](rspec.html)

Write specs for your Opal code RSpec and run them on Node.js or in a browser.

#### [Using Sprockets](using_sprockets.html)

Configure the long-lasting asset handler to work with Opal.

---

## Digging Deeper

#### [Configuring Gems](configuring_gems.html)

How to make your gem work in Opal and differentiate code for the JavaScript environment.

#### [Compiler](compiler.html)

A very general overview of how the Opal compiler works.

#### [Compiled Ruby and Raw JavaScript Interfaces](compiled_ruby.html)

This guide documents how each part of Ruby is mapped to JavaScript internally. This guide also gives
information on how to interface Ruby with JavaScript and vice-versa using raw interfaces.

#### [Compiler File Loading Directives](compiler_directives.html)

The Opal compiler supports some special directives that can optimize or
enhance the output of compiled Ruby code to suit the Ruby environment.

#### [Using the Opal parser inside a JavaScript environment](opal_parser.html)

This guide documents how to parse and run Ruby scripts within a browser or any supported JavaScript environment

#### [Encoding](encoding.html)

(WIP) How to handle encoding within Opal in the browser and in the code.

#### [Running code in a Headless Chrome](headless_chrome.html)

How to run your Opal application in a headless Chrome from the CLI instead of Node.js.

#### [Unsupported Features](unsupported_features.html)

Some things that are very difficult, impossible, or outright incompatible with a JavaScript environment.

---

## Releases

#### [Upgrading Opal](upgrading.html)

This guide provides steps to be followed when you upgrade your applications to a newer version of Opal.

#### [Releasing Instructions](releasing.html)

(WIP) A step-by-step guide on who to release a new version of Opal.

