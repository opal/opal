# Opal Rails

[![Build Status](https://secure.travis-ci.org/elia/opal-rails.png)](http://travis-ci.org/elia/opal-rails)
[![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/elia/opal-rails)

_Rails (3.2+) bindings for [Opal Ruby](http://opalrb.org) (v0.3.27) engine._



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

puts "G'day world!" # check the console
```




### As a template

You can use it for your views too, it even inherits instance and local variables from actions:

```ruby
# app/controllers/posts_controller.rb

def create
  @post = Post.create!(params[:post])
  render type: :js, locals: {comments_html: render_to_string(@post.comments)}
end
```

Each assign is filtered through JSON so it's reduced to basic types:

```ruby
# app/views/posts/cerate.js.opal

Document['.post .title'].html    = @post[:title]
Document['.post .body'].html     = @post[:body]
Document['.post .comments'].html = comments_html
```


### As an Haml filter (optional)

Of course you need to require `haml-rails` separately since its presence is not assumed

```haml
-# app/views/posts/show.html.haml

%article.post
  %h1.title= post.title
  .body= post.body

%a#show-comments Display Comments!

.comments(style="display:none;")
  - post.comments.each do |comment|
    .comment= comment.body

:opal
  Document.ready? do
    Document['#show-comments'].on :click do
      Document['.comments'].first.show
      false
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


## (Rails) Caveats

During eager loading (e.g. in production or test env) Rails loads all `.rb` files inside `app/` thus catching Opal files inside `app/assets` or `app/views`, the workaround for this is to add the following code to `application.rb`

```ruby
# Don't eager load stuff from app/assets and app/views
config.before_initialize do
  config.eager_load_paths = config.eager_load_paths.dup - Dir["#{Rails.root}/app/{assets,views}"]
end
```

**NOTE:** Rails does not do this on purpose, but the paths system (which states no eager loading for assets/views) is caught in a corner case here. I opened [an issue](rails/rails#???) on Rails already.



## License

© 2012 Elia Schito

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
