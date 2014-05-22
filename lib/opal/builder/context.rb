class Opal::Builder::Context
  def initialize(prerequired = nil, stubbed_files = nil)
    @prerequired        = prerequired   || []
    @stubbed_files      = stubbed_files || []
    @compiled_requires  = {}
    @assets             = []
    prerequire(@prerequired)
  end

  def prerequire(prerequires)
    @prerequired.concat(prerequires)
    prerequires.each {|pr| @compiled_requires[pr] = true}
  end

  def stub_files(files)
    @stubbed_files.concat(files)
  end

  def include? path
    compiled_requires.has_key?(path) #or stubbed_files.include?(path)
  end

  def sources
    assets.map(&:source)
  end

  def to_s
    sources.join("\n")
  end
  alias to_str to_s

  def inspect
    to_s.inspect
  end

  def source_map
    ''
  end

  def == other
    super or to_s == other
  end

  attr_reader :compiled_requires, :assets, :prerequired, :stubbed_files
end

