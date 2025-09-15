require 'opal'
require 'user'

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

$$.alert "The user is named #{bill.name}."

bill.authenticated?
