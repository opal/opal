require 'spec_helper'

describe 'opal core features', :js, :type => :request do
  before do
    Capybara.app = lambda do |env|
      path = env['PATH_INFO']
      base_path = File.expand_path('../../test/index.html', __FILE__)
  
      case path
      when /\.js/
        contents = File.read(File.join(File.dirname(base_path), '..', path))
        [200, {'Content-Type' => 'application/x-javascript'}, [contents]]
      else
        contents = File.read(base_path)
        [200, {'Content-Type' => 'text/html'}, [contents]]
      end 
    end
  end
  
  it 'runs all specs in the browser' do
    path = File.expand_path '../../test/index.html', __FILE__
    p path
    visit '/'
    within '.summary' do
      page.should have_content(' 0 failures ')
    end
  end
end
