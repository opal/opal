# backtick_javascript: true
# helpers: platform

# inspired by ruby/lib/tmpdir.rb

require 'fileutils'
require 'securerandom'

class ::Dir
  # Temporary name generator
  module Tmpname
    module_function

    MAX = 36**6

    # Unusable characters as path name
    UNUSABLE_CHARS = "^,-.0-9A-Z_a-z~"

    # Generates and yields random names to create a temporary name
    def create(basename, tmpdir=nil, max_try: nil, **opts)
      if tmpdir
        origdir = tmpdir = ::File.path(tmpdir)
        raise ::ArgumentError, "empty parent path" if tmpdir.empty?
      else
        tmpdir = ::Dir.tmpdir
      end
      n = nil
      prefix, suffix = basename
      prefix = (::String.try_convert(prefix) or raise(::ArgumentError, "unexpected prefix: #{prefix.inspect}"))
      prefix = prefix.delete(UNUSABLE_CHARS)
      suffix &&= (::String.try_convert(suffix) or raise(::ArgumentError, "unexpected suffix: #{suffix.inspect}"))
      suffix &&= suffix.delete(UNUSABLE_CHARS)
      begin
        t = ::Time.now.strftime("%Y%m%d")
        path = "#{prefix}#{t}-#{$$}-#{(::Random.urandom(4).unpack1("L")%MAX).to_s(36)}"\
                "#{n ? %[-#{n}] : ''}#{suffix||''}"
        path = ::File.join(tmpdir, path)
        yield(path, n, opts, origdir)
      rescue ::Errno::EEXIST
        n ||= 0
        n += 1
        retry if !max_try or n < max_try
        raise "cannot generate temporary name using '#{basename}' under '#{tmpdir}'"
      end
      path
    end
  end

  def self.mktmpdir(prefix_suffix = nil, *rest, **options)
    base = nil
    path = Tmpname.create(prefix_suffix || "d", *rest, **options) do |path, _, _, d|
      base = d
      mkdir(path, 0700)
    end
    return path unless block_given?
    begin
      yield path.dup
    ensure
      unless base
        base = ::File.dirname(path)
        stat = ::File.stat(base)
        if stat.world_writable? and `!$platform.windows` && !stat.sticky?
          raise ::ArgumentError, "parent directory is world writable but not sticky: #{base}"
        end
      end
      ::FileUtils.remove_entry path
    end
  end

  def self.tmpdir
    # Returns the operating system’s temporary file path
    `$platform.tmpdir()`
  end
end
