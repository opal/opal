require File.expand_path('../../../spec_helper', __FILE__)
require File.expand_path('../shared/index', __FILE__)

describe "Array#find_index" do
  ruby_version_is "1.8.7" do
    pending { it_behaves_like :array_index, :find_index }
  end
end
