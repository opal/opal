require 'bundler'
Bundler.require

require 'mspec/opal/rake_task'

::Opal::Processor.arity_check_enabled = true
::Opal::Processor.dynamic_require_severity = :raise

use Rack::ShowExceptions
use Rack::ShowStatus
use MSpec::Opal::Index
run MSpec::Opal::Environment.new


