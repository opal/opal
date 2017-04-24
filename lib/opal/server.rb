# frozen_string_literal: true
Opal.deprecation "`require 'opal/server` and `Opal::Server` are deprecated in favor of `require 'opal/sprockets/server'` and `Opal::Sprockets::Server` (now part of the opal-sprockets gem)."
require 'opal/sprockets/server'
Opal::Server = Opal::Sprockets::Server
