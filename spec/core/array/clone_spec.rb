require File.expand_path('../../../spec_helper', __FILE__)
require File.expand_path('../fixtures/classes', __FILE__)
require File.expand_path('../shared/clone', __FILE__)

describe "Array#clone" do
  it_behaves_like :array_clone, :clone
end
