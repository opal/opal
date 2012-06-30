require 'spec_helper'

describe '/opal_spec' do
  it 'runs all specs', :js do
    visit '/opal_spec'
    page.should have_content('Running: spec')
    page.should have_content('1 examples, 0 failures')
  end
end
