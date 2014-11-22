require 'opal'
require 'user'

module MyApp

  class Application
    def initialize
      @user = User.new('Bill')
      @user.authenticated?
    end
  end
end

MyApp::Application.new
