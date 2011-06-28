---
layout: main
title: "Opal documentation: String implementation"
---

String Implementation
=====================

Strings in Opal are immutable which means that their contents cannot
change once created. This means that various string methods like
`strip!` will not work, and an error will be thrown when called. Their
immutable counterpart methods are still available which typically return
a new string.

Implementation details
----------------------

Ruby strings are toll-free bridged to native javascript strings, meaning
that anywhere that a ruby stirng is required, a normal javascript string
may be passed. This dramatically improces the performance of opal due to
a lower overhead in the allocation of strings.

The immutability of javascript strings is directly the reason why
strings in opal are immutable.

Ruby compatibility
------------------


