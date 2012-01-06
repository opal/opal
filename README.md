Opal
====

Opal is a ruby to javascript compiler. Opal aims to take ruby files and generate
efficient javascript that maintains rubys features. Opal will, by default,
generate fast and efficient code in preference to keeping all ruby features.

Opal comes with an implementation of the ruby corelib, written in ruby, that
uses a bundled runtime (written in javascript) that tie all the features
together. Whenever possible Opal bridges to native javascript features under
the hood. The Opal gem includes the compiler used to convert ruby sources
into javascript.

For docs, visit the website:
[http://adambeynon.github.com/opal](http://adambeynon.github.com/opal)

Join the IRC channel on Freenode: `#opal`.
