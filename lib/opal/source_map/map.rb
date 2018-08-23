# frozen_string_literal: true

require 'base64'
require 'json'

module Opal::SourceMap::Map
  def to_h
    map
  end

  def to_json
    map.to_json
  end

  def as_json
    map.as_json
  end

  def to_s
    map.to_s
  end

  def to_data_uri_comment
    "//# sourceMappingURL=data:application/json;base64,#{Base64.encode64(to_json).delete("\n")}"
  end
end
