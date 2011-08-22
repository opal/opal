# module Opal::Rails::OpalContext
#   attr_accessor :opal_config
# end
# 
# module Opal::Rails::SprocketsConfig
#   def self.included(base)
#     base.alias_method_chain :asset_environment, :opal_config
#   end
# 
#   def asset_environment_with_opal_config(app, *args)
#     env = asset_environment_without_opal_config(app, *args)
#     env.context_class.extend(Opal::Rails::OpalContext)
#     env.context_class.opal_config = app.config.opal
#     env
#   end
# end
# 
# begin
#   # Before sprockets was extracted from rails
#   require 'sprockets/railtie'
#   module Sprockets
#     class Railtie < ::Rails::Railtie
#       include Opal::Rails::SprocketsConfig
#     end
#   end
# rescue LoadError
#   # After sprockets was extracted into sprockets-rails
#   require 'sprockets/rails/railtie'
#   module Sprockets
#     module Rails
#       class Railtie < ::Rails::Railtie
#         include Opal::Rails::SprocketsConfig
#       end
#     end
#   end
# end