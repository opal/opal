require 'spec_helper'

describe 'In-browser specs runner' do
  it 'runs all specs', :js do
    visit '/opal_spec'
    page.should have_content('Running: example_spec.js.rb')
    page.should have_content('1 examples, 0 failures')
  end
end
