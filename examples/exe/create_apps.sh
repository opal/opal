#!/bin/sh

# Comment those below, which are not installed or available for your platform,
# then execute this script to create some very simple apps.

# with node installed:
bundle exec opal --compile-to-exe node -o simple_node ./simple.rb

# it also works with eval:
bundle exec opal --compile-to-exe node -o eval_app_node -e 'puts "Hello from Opal in Node!"'
