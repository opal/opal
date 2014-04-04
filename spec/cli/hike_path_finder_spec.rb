require 'cli/spec_helper'
require 'cli/shared/path_finder_shared'
require 'opal/hike_path_finder'

describe Opal::HikePathFinder do
  subject(:path_finder) { described_class.new(root) }
  let(:root) { __dir__ }
  let(:path) { 'fixtures/opal_file' }
  let(:full_path) { File.join(root, path + ext) }
  let(:ext) { '.rb' }

  include_examples :path_finder
end
