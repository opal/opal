# backtick_javascript: true

require 'native'
require 'js-yaml-3-6-1'

module YAML
  @__yaml__ = `globalThis.jsyaml`
  `var __yaml__ = #{@__yaml__}`

  def self.load_path(path)
    load(`#{File}.__fs__.readFileSync(#{path}, 'utf8')`)
  end

  def self.load(data)
    loaded = `__yaml__.safeLoad(data)`
    loaded = Hash.new(loaded) if native?(loaded)
    loaded
  end
end
