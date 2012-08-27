<div class="hero-unit">
  <h1 class="main-title">Opal</h1>
  <p><strong>Opal is a ruby to javascript compiler</strong>. 
    Opal aims to take ruby files
and generate efficient javascript that maintains rubys features. Opal
will, by default, generate fast and efficient code in preference to
keeping all ruby features.
  </p>
  
  <p>
  Opal comes with an implementation of the ruby corelib, written in ruby,
  that uses a bundled runtime (written in javascript) that tie all the
  features together. Whenever possible Opal bridges to native javascript
  features under the hood. The Opal gem includes the compiler used to
  convert ruby sources into javascript.
  </p>

  <p>
    Opal is <a href="http://github.com/adambeynon/opal">hosted on github</a>,
    and there is a Freenode IRC channel at <code>#opal</code>.
</div>

<div class="row-fluid">
  <div class="span4">
    <h2>Source-to-source</h2>
    <p>
      The generated javascript code is one to one, and no virtual machine
      makes opal very fast. A ruby method call is compiled directly into a
      javascript function call. Fast, small and easy to read/debug.
      <a href="/implementation">Learn more about the implementation.</a>
    </p>
  </div>

  <div class="span4">
    <h2>Small Runtime</h2>
    <p>
      Opal features a runtime and corelib implementation that is only
      <strong>13.1kb</strong> minified and gzipped. This small footprint
      makes opal such a small dependency for applications.
    </p>
  </div>

  <div class="span4">
    <h2>Fully Open Source</h2>
    <p>
      Opal is released under the MIT license, and it is <a href="http://github.com/adambeynon/opal">
      hosted on github</a> so fork and hack away!
    </p>
  </div>
</div>