# Interfacing with JavaScript

## The `Native` Module Guide

### Introduction

This guide is dedicated to helping Ruby developers, from beginners to seasoned pros, to seamlessly work with JavaScript environments using Opal's `Native` module. We aim to provide a clear pathway for Rubyists to harness the power of JavaScript without stepping away from the comfort of Ruby syntax.

### Getting Started with the `Native` Module

#### Setting Up

To start using the `Native` module in your project, require it at the beginning of your Ruby file:

```ruby
require 'native'
```

This line loads the `Native` module, granting you access to JavaScript's global objects, functions, and properties directly from Ruby.

### Basics of `Native` Module Usage

#### Accessing JavaScript Global Objects

The global JavaScript object, typically `window` in a browser environment, can be referenced in Opal using the `$$` or `$global` variables:

```ruby
win = $$  # References the global JavaScript `window` object
```

#### Reading and Writing Properties

Access and modify JavaScript object properties straightforwardly:

```ruby
# Access a property
puts win[:location][:href]  # Output: the current page URL

# Modify a property
win[:location][:href] = "https://example.com"  # Redirects the browser to example.com
```

#### Calling JavaScript Methods

Invoke methods on JavaScript objects with ease:

```ruby
win.alert('Hello, Opal!')
```

#### Enhancing JavaScript Objects with Ruby

You can define Ruby methods on JavaScript objects for more complex interactions:

```ruby
class << win
  def close!
    close  # Calls the JavaScript close method on the window object
  end

  def href=(url)
    self[:location][:href] = url
  end
end

win.href = "https://example.com"  # Sets the page URL
win.close!  # Closes the browser window
```
