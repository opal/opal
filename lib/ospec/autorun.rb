require 'ospec'

if RUBY_ENGINE == 'opal-browser'
  Spec::Runner.autorun_browser
else
  Spec::Runner.autorun
end

