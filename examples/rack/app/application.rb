require 'opal'
require 'user'
require 'opal/platform'

module MyApp
  class Application
    def initialize
      @user = User.new('Bob')
    end

    def title
      "#{@user.name} is #{:not unless @user.authenticated?} authenticated"
    end
  end
end

$app = MyApp::Application.new

require 'native'

$$[:document][:title] = "#{$app.title}"

bill = User.new('Bill')
bill.authenticated?
