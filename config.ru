require 'bundler'
Bundler.require

require 'mspec/opal/rake_task'

::Opal::Config.arity_check_enabled = true
::Opal::Config.dynamic_require_severity = :error

use Rack::ShowExceptions
use Rack::ShowStatus
use MSpec::Opal::Index
run MSpec::Opal::Environment.new


