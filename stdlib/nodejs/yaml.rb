require 'native'

module YAML
  `var __yaml__ = OpalNode.node_require('js-yaml')`

  def self.load_path path
    loaded = `__yaml__.yaml.safeLoad(#{File.__fs__}.readFileSync(#{path}, 'utf8'))`
    loaded = Hash.new(loaded) if native?(loaded)
    loaded
  end
end
