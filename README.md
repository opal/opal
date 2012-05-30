# Opal/Rails adapter

For Rails 3.2 only.


## Installation

In your `Gemfile`

``` ruby
gem 'opal-rails'
```


## Usage

### Asset Pipeline

``` js
// app/assets/application.js

// The main Opal VM
// require opal

// optional jQuery-like DOM manipulation for Opal
// require rquery
```

and then just use the `.opal` extensions:

```ruby
# app/assets/javascripts/hi-world.js.opal

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



## Licence

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
