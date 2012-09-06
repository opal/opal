# Opal Rails

_Rails (3.2+) bindings for [Opal JS](http://opalrb.org) engine._


## Installation

In your `Gemfile`

``` ruby
gem 'opal-rails'
```


## Usage

### Asset Pipeline

``` js
// app/assets/application.js

// The Opal runtime
// = require opal
//
// Dom manipulation
// = require jquery
// = require opal-jquery
```

and then just use the `.rb` or `.opal` extensions:

```ruby
# app/assets/javascripts/hi-world.js.rb

puts "G'day world!"
```



### As a template

You can use it for your dynamic templates too (Probably in conjunction with ERB to pass dynamic state)

```ruby
# app/views/posts/show.js.opal.erb

Element.id('<%= dom_id @post %>').show
```


### As an Haml filter (optional)

Of course you need to require `haml-rails` separately since its presence is not assumed

```haml
-# app/views/posts/show.html.haml

%article= post.body

%a#show-comments Display Comments!

.comments(style="display:none;")
  - post.comments.each do |comment|
    .comment= comment.body

:opal
  Document.ready? do
    Element.id('show-comments').on :click do
      Element.find('.comments').first.show
      false # aka preventDefault
    end
  end
```


### Spec!

Add a `spec.js` into `assets/javascripts` to require your specs

```js
// = require_tree ./spec
```

and then a spec folder with you specs!

```ruby
# assets/javascripts/spec/example_spec.js.rb

describe 'a spec' do
  it 'has successful examples' do
    'I run'.should =~ /run/
  end
end
```

Then visit `/opal_spec` from your app and **reload at will**.

![1 examples, 0 failures](http://f.cl.ly/items/001n0V0g0u0v14160W2G/Schermata%2007-2456110%20alle%201.06.29%20am.png)




## License

Copyright © 2012 by Elia Schito

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
