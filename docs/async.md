# Asynchronous code (PromiseV2 / async / await)

Please be aware that this functionality is marked as experimental and may change
in the future.

In order to disable the warnings that will be shown if you use those experimental
features, add the following line before requiring `promise/v2` or `await` and after
requiring `opal`.

```ruby
`Opal.config.experimental_features_severity = 'ignore'`
```

## PromiseV2

In Opal 1.2 we introduced PromiseV2 which is to replace the default Promise in Opal 2.0
(which will become PromiseV1). Right now it's experimental, but the interface of PromiseV1
stay unchanged and will continue to be supported.

It is imperative that during the transition period you either `require 'promise/v1'` or
`require 'promise/v2'` and then use either `PromiseV1` or `PromiseV2`.

If you write library code it's imperative that you don't require the promise itself, but
detect if `PromiseV2` is defined and use the newer implementation, for instance using the
following code:

```ruby
module MyLibrary
  Promise = defined?(PromiseV2) ? PromiseV2 : ::Promise
end
```

The difference between `PromiseV1` and `PromiseV2` is that `PromiseV1` is a pure-Ruby
implementation of a Promise, while `PromiseV2` is reusing the JavaScript `Promise`. Both are
incompatible with each other, but `PromiseV2` can be awaited (see below) and they translate
1 to 1 to the JavaScript native `Promise` (they are bridged; you can directly return a
`Promise` from JavaScript API without a need to translate it). The other difference is that
`PromiseV2` always runs a `#then` block a tick later, while `PromiseV1` would could run it
instantaneously.

## Async/await

In Opal 1.3 we implemented the CoffeeScript pattern of async/await. As of now, it's hidden
behind a magic comment, but this behavior may change in the future.

Example:

```ruby
# await: true

require "await"

def wait_5_seconds
  puts "Let's wait 5 seconds..."
  sleep(5).await
  puts "Done!"
end

wait_5_seconds.await
```

It's important to understand what happens under the hood: every scope in which `#await` is
encountered will become async, which means that it will return a Promise that will resolve
to a value. This includes methods, blocks and the top scope. This means, that `#await` is
infectious and you need to remember to `#await` everything along the way, otherwise
a program will finish too early and the values may be incorrect.

[You can take a look at how we ported Minitest to support asynchronous tests.](https://github.com/opal/opal/pull/2221/commits/8383c7b45a94fe4628778f429508b9c08c8948b0)

It is certainly correct to `#await` any value, including non-Promises, for instance
`5.await` will correctly resolve to `5` (except that it will make the scope an async
function, with all the limitations described above).

The `await` stdlib module includes a few useful functions, like async-aware `each_await`
function and `sleep` that doesn't block the thread.

This approach is certainly incompatible with what Ruby does, but due to a dynamic nature
of Ruby and a different model of JavaScript this was the least invasive way to catch up
with the latest JavaScript trends and support `Promise` heavy APIs and asynchronous code.

## Auto-await

The magic comment also accepts a comma-separated list of methods to be automatically
awaited. A special value of `suffix` will automatically await any method which name ends
with `_await` (or `_await?`, `_await!`, `_await=`). For instance, those two blocks of
code are equivalent:

```ruby
# await: true

require "await"

[1,2,3].each_await do |i|
  p i
  sleep(i).await
end.await
```

```ruby
# await: sleep, suffix

require "await"

[1,2,3].each_await do |i|
  p i
  sleep i
end
```