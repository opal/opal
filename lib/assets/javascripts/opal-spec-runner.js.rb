require 'jquery'

require 'opal'
require 'opal-spec'
require 'opal-jquery'

Document.ready? do
  Opal::Spec::Runner.new.run
end
