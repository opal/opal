# frozen_string_literal: true

require 'opal/paths'

if RUBY_ENGINE != 'opal'
  require 'fileutils'
  require 'digest/sha2'
  require 'zlib'
end

module Opal
  singleton_class.attr_writer :cache

  def self.cache
    @cache ||=
      if RUBY_ENGINE == 'opal' || ENV['OPAL_CACHE_DISABLE'] || !Cache::FileCache.find_dir
        Cache::NullCache.new
      else
        Cache::FileCache.new
      end
  end

  class Cache
    class CacheError < StandardError; end

    class NullCache
      def fetch(*)
        yield
      end
    end

    unless RUBY_ENGINE == 'opal'
      class FileCache
        def initialize(dir: nil, max_size: nil)
          @dir = dir || self.class.find_dir
          @root = File.expand_path('..', Opal.gem_dir)
          # Store at most 32MB of cache - de facto this 32MB is larger,
          # as we don't account for inode size for instance. In fact, it's
          # about 50M. Also we run this check before anything runs, so things
          # may go up to 64M or even larger.
          @max_size = max_size || 32 * 1024 * 1024

          tidy_up_cache
        end

        def fetch(*key)
          key = key.join('/')
          file = cache_filename_for(key)

          if File.exist?(file)
            data = load_data(file)
          end

          if data
            data
          else
            compiler = yield
            store_data(file, compiler)
            compiler
          end
        end

        private def store_data(file, data)
          out = Marshal.dump(data)
          out = Zlib.gzip(out, level: 9)
          File.binwrite(file, out)
        end

        private def load_data(file)
          FileUtils.touch(file)
          out = File.binread(file)
          out = Zlib.gunzip(out)
          Marshal.load(out) # rubocop:disable Security/MarshalLoad
        rescue Zlib::GzipFile::Error
          nil
        end

        # Remove cache entries that overflow our cache limit... and which
        # were used least recently.
        private def tidy_up_cache
          entries = Dir[@dir + '/*.rbm.gz']

          size_sum = entries.map { |i| File.size(i) }.sum
          return unless size_sum > @max_size

          # First, we try to get the oldest files first.
          entries = entries.sort_by { |i| File.mtime(i) }
          # Then, what's more important, is that we try to get the least
          # recently used files first. Filesystems with relatime or noatime
          # will get this wrong, but it doesn't matter that much, because
          # the previous sort got things "maybe right".
          entries = entries.sort_by { |i| File.atime(i) }

          entries.each do |i|
            size_sum -= File.size(i)
            File.unlink(i)

            # We don't need to work this out anymore - we reached out goal.
            break unless size_sum > @max_size
          end
        end

        # This complex piece of code tries to check if we can robustly mkdir_p a directory.
        def self.dir_writable?(*paths)
          dir = nil
          paths = paths.reduce([]) do |a, b|
            [*a, dir = a.last ? File.expand_path(b, a.last) : b]
          end

          File.exist?(paths.first) &&
            paths.reverse.all? do |i|
              !File.exist?(i) || (File.directory?(i) && File.writable?(i))
            end

          dir
        end

        def self.find_dir
          @find_dir ||= case
                        # Try to write cache into a directory pointed by an environment variable if present
                        when dir = ENV['OPAL_CACHE_DIR']
                          FileUtils.mkdir_p(dir)
                          dir
                        # Otherwise, we write to the place where Opal is installed...
                        # I don't think it's a good location to store cache, so many things can go wrong.
                        # when dir = dir_writable?(Opal.gem_dir, '..', 'tmp', 'cache')
                        #   FileUtils.mkdir_p(dir)
                        #   FileUtils.chmod(0o700, dir)
                        #   dir
                        # Otherwise, ~/.cache/opal...
                        when dir = dir_writable?(Dir.home, '.cache', 'opal')
                          FileUtils.mkdir_p(dir)
                          FileUtils.chmod(0o700, dir)
                          dir
                        # Only /tmp is writable... or isn't it?
                        when (dir = dir_writable?('/tmp', "opal-cache-#{ENV['USER']}")) && File.sticky?('/tmp')
                          FileUtils.mkdir_p(dir)
                          FileUtils.chmod(0o700, dir)
                          dir
                        # No way... we can't write anywhere...
                        else
                          warn "Couldn't find a writable path to store Opal cache. " \
                               'Try setting OPAL_CACHE_DIR environment variable'
                          nil
                        end
        end

        private def cache_filename_for(key)
          "#{@dir}/#{runtime_hash}-#{hash key}.rbm.gz"
        end

        private def hash(object)
          digest object.inspect
        end

        private def digest(string)
          Digest::SHA256.hexdigest(string)[-32..-1].to_i(16).to_s(36)
        end

        private def runtime_hash
          # Re-compute runtime hash if some compiler options changed during the process.
          compiler_options = Opal::Config.compiler_options.inspect
          @runtime_hash = nil if @compiler_options != compiler_options
          @runtime_hash ||= begin
            # We want to ensure the compiler and any Gemfile/gemspec (for development)
            # stays untouched
            files = Dir["#{@root}/{Gemfile*,*.gemspec,lib/**/*}"]

            # Also check if parser wasn't changed:
            files += $LOADED_FEATURES.grep(%r{lib/(parser|ast)})

            digest [
              files.sort.map { |f| "#{f}:#{File.size(f)}:#{File.mtime(f).to_f}" },
              @compiler_options = compiler_options,
              RUBY_VERSION,
              RUBY_PATCHLEVEL
            ].join('/')
          end
        end
      end
    end
  end
end
