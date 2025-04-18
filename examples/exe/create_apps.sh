#!/bin/sh

# Comment those below, which are not installed or available for your platform,
# then execute this script to create some very simple apps.

# with bun installed:
bundle exec opal --compile-to-exe bun -o simple_bun ./simple.rb

# with deno installed:
bundle exec opal --compile-to-exe deno -o simple_deno ./simple.rb

# with node installed:
bundle exec opal --compile-to-exe node -o simple_node ./simple.rb

# with quickjs installed:
bundle exec opal --compile-to-exe quickjs -o simple_quickjs ./simple.rb

# it also works with eval:
bundle exec opal --compile-to-exe quickjs -o eval_app_quickjs -e 'puts "Hello from Opal in QuickJS!"'
