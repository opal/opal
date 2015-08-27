# FAQ

### Why does Opal exist?

To try and keep ruby relevant in a world where client-side apps are making javascript the primary development platform.

### How compatible is Opal?

We run opal against [rubyspec](https://github.com/rubyspec/rubyspec) as our primary testing setup. We try to make Opal as compatible as possible, whilst also taking into account restrictions of Javascript when applicable. Opal supports the majority of ruby syntax features, as well as a very large part of the corelib implementation. We support method\_missing, modules, classes, instance\_exec, blocks, procs and lots lots more. Opal can compile and run Rspec unmodified, as well as self hosting the compiler at runtime.

### What version of ruby does Opal target?

We are running tests under ruby 2.0.0 conditions, but are mostly compatible with 1.9 level features.

### Why doesn't Opal support mutable strings?

All strings in Opal are immutable because ruby strings just get compiled direclty into javascript strings, which are immutable. Wrapping ruby strings as a custom Javascript object would add a lot of overhead as well as making interaction between ruby and javascript libraries more difficult.
