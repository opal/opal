# make sure these tests are indeed running inside opal, not any other
# ruby engine.
unless RUBY_ENGINE =~ /opal/
  abort <<-EOS
Opal Tests
==========

These tests MUST be run inside opal, not `#{RUBY_ENGINE}' engine

To run Array#first tests, for example:

    opal core_spec/core/array/first_spec.rb

EOS
end

require 'opal/spec/autorun'

# Spec runner - if in browser, and spec_helper.rb is the main file then
# just run the spec files immediately.
if $0 == __FILE__
  Dir['spec/**/*.rb'].each { |spec| require spec }
end
