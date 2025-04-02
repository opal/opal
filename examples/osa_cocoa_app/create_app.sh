#!/bin/sh
# on macOS only:
# use -E or --no-exit to keep the app open for UI interactions
bundle exec opal --create-app osascript -o Button -E ./button.rb
