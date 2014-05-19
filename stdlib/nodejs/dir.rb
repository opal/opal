class Dir
  def self.[] glob
    `#{__glob__}.sync(#{glob})`
  end

  def self.__glob__
    @__glob__ ||= `OpalNode.node_require('glob')`
  end
end
