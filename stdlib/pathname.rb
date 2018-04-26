require 'corelib/comparable'

# Portions from Author:: Tanaka Akira <akr@m17n.org>
class Pathname
  include Comparable
  SEPARATOR_PAT = /#{Regexp.quote File::SEPARATOR}/

  def initialize(path)
    if Pathname === path
      @path = path.path.to_s
    elsif path.respond_to?(:to_path)
      @path = path.to_path
    elsif path.is_a?(String)
      @path = path
    elsif path.nil?
      raise TypeError, 'no implicit conversion of nil into String'
    else
      raise TypeError, "no implicit conversion of #{path.class} into String"
    end
    raise ArgumentError if @path == "\0"
  end

  attr_reader :path

  def ==(other)
    other.path == @path
  end

  def absolute?
    !relative?
  end

  def relative?
    path = @path
    while (r = chop_basename(path))
      path, = r
    end
    path == ''
  end

  def chop_basename(path) # :nodoc:
    base = File.basename(path)
    # ruby uses /^#{SEPARATOR_PAT}?$/o but having issues with interpolation
    if Regexp.new("^#{Pathname::SEPARATOR_PAT.source}?$") =~ base
      return nil
    else
      return path[0, path.rindex(base)], base
    end
  end

  def root?
    @path == '/'
  end

  def parent
    new_path = @path.sub(%r{/([^/]+/?$)}, '')
    new_path = absolute? ? '/' : '.' if new_path == ''
    Pathname.new(new_path)
  end

  def sub(*args)
    Pathname.new(@path.sub(*args))
  end

  def cleanpath
    `return Opal.normalize(#{@path})`
  end

  def to_path
    @path
  end

  def hash
    @path
  end

  def expand_path
    Pathname.new(File.expand_path(@path))
  end

  def +(other)
    other = Pathname.new(other) unless Pathname === other
    Pathname.new(plus(@path, other.to_s))
  end

  def plus(path1, path2) # -> path # :nodoc:
    prefix2 = path2
    index_list2 = []
    basename_list2 = []
    while (r2 = chop_basename(prefix2))
      prefix2, basename2 = r2
      index_list2.unshift prefix2.length
      basename_list2.unshift basename2
    end
    return path2 if prefix2 != ''
    prefix1 = path1
    while true
      while !basename_list2.empty? && basename_list2.first == '.'
        index_list2.shift
        basename_list2.shift
      end
      break unless (r1 = chop_basename(prefix1))
      prefix1, basename1 = r1
      next if basename1 == '.'
      if basename1 == '..' || basename_list2.empty? || basename_list2.first != '..'
        prefix1 += basename1
        break
      end
      index_list2.shift
      basename_list2.shift
    end
    r1 = chop_basename(prefix1)
    if !r1 && /#{SEPARATOR_PAT}/ =~ File.basename(prefix1)
      while !basename_list2.empty? && basename_list2.first == '..'
        index_list2.shift
        basename_list2.shift
      end
    end
    if !basename_list2.empty?
      suffix2 = path2[index_list2.first..-1]
      r1 ? File.join(prefix1, suffix2) : prefix1 + suffix2
    else
      r1 ? prefix1 : File.dirname(prefix1)
    end
  end

  def join(*args)
    return self if args.empty?
    result = args.pop
    result = Pathname.new(result) unless Pathname === result
    return result if result.absolute?
    args.reverse_each do |arg|
      arg = Pathname.new(arg) unless Pathname === arg
      result = arg + result
      return result if result.absolute?
    end
    self + result
  end

  def split
    [dirname, basename]
  end

  def dirname
    Pathname.new(File.dirname(@path))
  end

  def basename
    Pathname.new(File.basename(@path))
  end

  def directory?
    File.directory?(@path)
  end

  def extname
    File.extname(@path)
  end

  def <=>(other)
    path <=> other.path
  end

  alias eql? ==
  alias === ==

  alias to_str to_path
  alias to_s to_path

  SAME_PATHS = if File::FNM_SYSCASE.nonzero?
                 # Avoid #zero? here because #casecmp can return nil.
                 proc { |a, b| a.casecmp(b) == 0 }
               else
                 proc { |a, b| a == b }
               end

  def relative_path_from(base_directory)
    dest_directory = cleanpath.to_s
    base_directory = base_directory.cleanpath.to_s
    dest_prefix = dest_directory
    dest_names = []
    while (r = chop_basename(dest_prefix))
      dest_prefix, basename = r
      dest_names.unshift basename if basename != '.'
    end
    base_prefix = base_directory
    base_names = []
    while (r = chop_basename(base_prefix))
      base_prefix, basename = r
      base_names.unshift basename if basename != '.'
    end
    unless SAME_PATHS[dest_prefix, base_prefix]
      raise ArgumentError, "different prefix: #{dest_prefix.inspect} and #{base_directory.inspect}"
    end
    while !dest_names.empty? &&
          !base_names.empty? &&
          SAME_PATHS[dest_names.first, base_names.first]
      dest_names.shift
      base_names.shift
    end
    if base_names.include? '..'
      raise ArgumentError, "base_directory has ..: #{base_directory.inspect}"
    end
    base_names.fill('..')
    relpath_names = base_names + dest_names
    if relpath_names.empty?
      Pathname.new('.')
    else
      Pathname.new(File.join(*relpath_names))
    end
  end

  def entries
    Dir.entries(@path).map { |f| self.class.new(f) }
  end
end

module Kernel
  def Pathname(path)
    Pathname.new(path)
  end
end
