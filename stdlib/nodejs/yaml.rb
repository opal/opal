require 'native'

module YAML
  NATIVE = node_require('js-yaml')

  def self.load_path path
    loaded = `#{NATIVE}.yaml.safeLoad(#{File.__fs__}.readFileSync(#{path}, 'utf8'))`
    loaded = Hash.new(loaded) if native?(loaded)
    loaded
  end
end
