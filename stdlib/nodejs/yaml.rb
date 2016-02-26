require 'native'

module YAML
  @__yaml__ = node_require 'js-yaml'
  `var __yaml__ = #{@__yaml__}`

  def self.load_path path
    loaded = `__yaml__.safeLoad(#{File}.__fs__.readFileSync(#{path}, 'utf8'))`
    loaded = Hash.new(loaded) if native?(loaded)
    loaded
  end
end
