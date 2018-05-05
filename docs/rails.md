# Opal in a Rails application

Add Opal to your Rails app's Gemfile:

``` ruby
gem 'opal-rails'
```

## Basic usage through the asset pipeline

To configure your asset pipeline to use opal-rails, make sure to `bundle install`, then rename 
`app/assets/application.js` to `app/assets/application.js.rb` and set its contents to: 

```ruby
# app/assets/application.js.rb

# Require the opal runtime and core library
require 'opal'

# For Rails 5.1 and above, otherwise use 'opal_ujs'
require 'rails_ujs'

# Require of JS libraries will be forwarded to sprockets as is
require 'turbolinks'

# a Ruby equivalent of the require_tree Sprockets directive is available
require_tree '.'
```

Opal requires are forwarded to the Asset Pipeline at compile time (similarly to what happens for RubyMotion). You can use either the `.rb` or `.opal` extension:

```ruby
# app/assets/javascripts/greeter.js.rb

puts "G'day world!" # check the console!

# Dom manipulation
require 'opal-jquery'

Document.ready? do
  Element.find('body > header').html = '<h1>Hi there!</h1>'
end
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
# app/views/posts/create.js.opal

post = Element.find('.post')
post.find('.title').html    = @post[:title]
post.find('.body').html     = @post[:body]
post.find('.comments').html = comments_html
```


### As a Haml filter (optional)

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
    Element.find('#show-comments').on :click do |click|
      click.prevent_default
      click.current_target.hide
      Element.find('.comments').effect(:fade_in)
    end
  end
```


### Spec!

Add specs into `app/assets/javascripts/spec`:

and then a spec folder with you specs!

```ruby
# app/assets/javascripts/spec/example_spec.js.rb

describe 'a spec' do
  it 'has successful examples' do
    'I run'.should =~ /run/
  end
end
```

Then visit `/opal_spec` from your app and **reload at will**.

![1 examples, 0 failures](http://f.cl.ly/items/001n0V0g0u0v14160W2G/Schermata%2007-2456110%20alle%201.06.29%20am.png)

