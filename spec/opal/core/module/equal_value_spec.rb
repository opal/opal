require 'spec_helper'
require_relative 'fixtures/classes'
require_relative '../../../ruby/core/module/shared/equal_value'

describe "Module#==" do
  it_behaves_like :module_equal, :==
end
