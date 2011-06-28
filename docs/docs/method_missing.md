---
layout: main
title: "Opal: method\_missing Documentation"
---

Method Missing
==============

Opal supports method\_missing as a core feature of ruby. To make method
calls as fast as possible, opal objects and classes just fall back to
regular javascript prototypes for holding methods on the receiver, but
the runtime modifies them in distinct ways to handle module includes,
inheritence and method missing calls.

