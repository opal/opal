# Promise

`Promise` is a class available in the Opal stdlib for helping structure asynchronous code.

It can be required inside any Opal applicaton:

```ruby
require 'promise'
```

_Please also take a look at the Asynchronous code guide - we are in the process of modernizing the Promises, along with supporting async/await_

## Usage

This example shows how to use a `HTTP` request from `opal-jquery` from a callback style, into a promise style handler.

```ruby
def get_json(url)
  promise = Promise.new

  HTTP.get(url) do |response|
    if response.ok?
      promise.resolve response.json
    else
      promise.reject response
    end
  end

  promise
end

get_json('/users/1.json').then do |json|
  puts "Got data: #{json}"
end.fail do |res|
  alert "It didn't work :( #{res}"
end
```

A promise can only be resolved or rejected once.

### Chaining Promises

Promises become useful when chained together. The previous example could be extended to get another object from the result of the first request.

```ruby
get_json('/users/1.json').then do |json|
  get_json("/posts/#{json[:post_id]}.json")
end.then do |post|
  puts "got post: #{post}"
end
```

### Composing Promises

`Promise.when` can be used to wait for more than 1 promise to resolve (or reject). Lets assume we wanted to get 2 different users:

```ruby
first = get_json '/users/1.json'
second = get_json '/users/2.json'

Promise.when(first, second).then do |user1, user2|
  puts "got users: #{user1}, #{user2}"
end.fail do
  alert "Something bad happened"
end
```
