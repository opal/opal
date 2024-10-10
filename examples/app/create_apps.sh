#!/bin/sh

# Comment those below, which are not installed or available for your platform,
# then execute this script to create some very simple apps.

# with bun installed:
bundle exec opal --create-app bun -o simple_bun ./simple.rb

# with deno installed:
bundle exec opal --create-app deno -o simple_deno ./simple.rb

# with node installed:
bundle exec opal --create-app node -o simple_node ./simple.rb

# on macOS only:
bundle exec opal --create-app osa -o simple_osa ./simple.rb
# execute the macOS app from the terminal as:
# ./simple_osa.app/Contents/MacOS/applet

# with quickjs installed:
bundle exec opal --create-app quickjs -o simple_quickjs ./simple.rb

# it also works with eval:
bundle exec opal --create-app quickjs -o eval_app_quickjs -e 'puts "Hello from Opal in QuickJS!"'
