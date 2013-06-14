# need this spec here since bootstrap requires use of ENV predefined object
describe "includes a hash-like object ENV" do
  Object.const_defined?(:ENV).should == true
  ENV.respond_to?(:[]).should == true
end

ENV['MSPEC_RUNNER'] = true

unless ENV['MSPEC_RUNNER']
  begin
    require "pp"
    require 'mspec/version'
    require 'mspec/helpers'
    require 'mspec/guards'
    require 'mspec/runner/shared'
    require 'mspec/matchers/be_ancestor_of'
    require 'mspec/matchers/output'
    require 'mspec/matchers/output_to_fd'
    require 'mspec/matchers/complain'
    require 'mspec/matchers/equal_element'
    require 'mspec/matchers/equal_utf16'
    require 'mspec/matchers/match_yaml'
    require 'mspec/matchers/have_class_variable'
    require 'mspec/matchers/have_constant'
    require 'mspec/matchers/have_instance_method'
    require 'mspec/matchers/have_instance_variable'
    require 'mspec/matchers/have_method'
    require 'mspec/matchers/have_private_instance_method'
    require 'mspec/matchers/have_protected_instance_method'
    require 'mspec/matchers/have_public_instance_method'

    # Code to setup HOME directory correctly on Windows
    # This duplicates Ruby 1.9 semantics for defining HOME
    platform_is :windows do
      if ENV['HOME']
        ENV['HOME'] = ENV['HOME'].tr '\\', '/'
      elsif ENV['HOMEDIR'] && ENV['HOMEDRIVE']
        ENV['HOME'] = File.join(ENV['HOMEDRIVE'], ENV['HOMEDIR'])
      elsif ENV['HOMEDIR']
        ENV['HOME'] = ENV['HOMEDIR']
      elsif ENV['HOMEDRIVE']
        ENV['HOME'] = ENV['HOMEDRIVE']
      elsif ENV['USERPROFILE']
        ENV['HOME'] = ENV['USERPROFILE']
      else
        puts "No suitable HOME environment found. This means that all of"
        puts "HOME, HOMEDIR, HOMEDRIVE, and USERPROFILE are not set"
        exit 1
      end
    end

    TOLERANCE = 0.00003 unless Object.const_defined?(:TOLERANCE)
  rescue LoadError
    puts "Please install the MSpec gem to run the specs."
    exit 1
  end
end

CODE_LOADING_DIR = File.expand_path "../fixtures/code", __FILE__

minimum_version = "1.5.17"
unless MSpec::VERSION >= minimum_version
  puts "Please install MSpec version >= #{minimum_version} to run the specs"
  exit 1
end

$VERBOSE = nil unless ENV['OUTPUT_WARNINGS']


# Waiting for: https://github.com/rubyspec/mspec/pull/40
require 'mspec/guards/guard'

class SpecGuard
  def implementation?(*args)
    args.any? do |name|
      !!case name
      when :rubinius
        RUBY_NAME =~ /^rbx/
      when :ruby
        RUBY_NAME =~ /^ruby/
      when :jruby
        RUBY_NAME =~ /^jruby/
      when :ironruby
        RUBY_NAME =~ /^ironruby/
      when :macruby
        RUBY_NAME =~ /^macruby/
      when :maglev
        RUBY_NAME =~ /^maglev/
      when :topaz
        RUBY_NAME =~ /^topaz/
      when :opal
        RUBY_NAME =~ /^opal/
      else
        false
      end
    end
  end
end
