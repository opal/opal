require 'opal'
require 'opal/sprockets'

module Opal::Sprockets::MainProcessor
  def self.call input
    asset_name      = input[:name]
    environment     = input[:environment]
    opal_asset      = -> asset { File.extname(asset.filename) == '.rb' }
    required        = input[:metadata][:required].map(&environment.method(:find_asset))
    non_opal_assets = required.reject(&opal_asset).map{|a| a.to_hash[:name]}.to_set
    stubbed_files   = ::Opal::Config.stubbed_files.to_set
    loaded          = non_opal_assets + stubbed_files

    data = [input[:data], ';']
    data << "Opal.loaded(#{loaded.to_json});" unless loaded.empty?
    data << "Opal.load(#{asset_name.to_json});"
    data.join("\n")
  end
end

Sprockets.register_engine '.opal_main', Opal::Sprockets::MainProcessor, mime_type: 'application/javascript'

