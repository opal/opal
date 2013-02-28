module Kernel
  def describe(desc, &block)
    group = OSpec::Group.create(desc, block)

    stack = OSpec::Group.stack
    stack << group
    group.class_eval &block
    stack.pop
  end

  def mock(obj)
    Object.new
  end

  # Used for splitting specific ruby version tests. For now we allow all test
  # groups to run (as opal isnt really a specific ruby version as such?)
  def ruby_version_is(version, &block)
    if String === version
      block.call if version == "1.9"
    elsif Range === version
      block.call if version === "1.9"
    end
  end

  def enumerator_class
    Enumerator
  end
end
