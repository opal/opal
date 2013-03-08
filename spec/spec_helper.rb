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

  rescue LoadError
  end
end

