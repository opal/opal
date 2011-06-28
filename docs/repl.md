---
layout: main
title: "Opal: Try Opal in the browser"
---

# Opal REPL

This page provides a simple REPL that is built into the opal build tools
and is easily loaded on any page with:

{% highlight javascript %}
opal.browser_repl();
{% endhighlight %}

The REPL simply takes single lines of ruby and evaluates them against
the top level object in ruby. There are some limitations to this repl at
the moment, which includes the inability to have multi line statements
(each statement is evaluated once return is pressed). Also only the core
opal libraires are loaded, so there is no access to RQuery and other
libraries.

<script src="js/opal.js"></script>
<script src="js/opal-parser.js"></script>

[OK, load REPL!](javascript:opal.browser_repl(\);)
