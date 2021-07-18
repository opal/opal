# frozen_string_literal: true

require 'base64'
require 'json'

module Opal::SourceMap::Map
  def to_h
    @to_h || map
  end

  def to_json
    to_h.to_json
  end

  def as_json(*)
    to_h
  end

  def to_s
    to_h.to_s
  end

  def to_data_uri_comment
    "//# sourceMappingURL=data:application/json;base64,#{Base64.encode64(to_json).delete("\n")}"
  end

  # Marshaling for cache shortpath
  def cache
    @to_h ||= map
    self
  end

  def marshal_dump
    [to_h, generated_code]
  end

  def marshal_load(value)
    @to_h, @generated_code = value
  end
end
