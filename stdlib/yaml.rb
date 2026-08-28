# backtick_javascript: true

require 'native'
require 'yaml/js-yaml-3-6-1'

module YAML
  @__yaml__ = `globalThis.jsyaml`
  `var __yaml__ = #{@__yaml__}`

  def self.load_path(path)
    load(File.read(path))
  end

  def self.load(data)
    loaded = `__yaml__.safeLoad(data)`
    loaded = Hash.new(loaded) if native?(loaded)
    loaded
  end

  def self.safe_load(data)
    load(data)
  end
end
