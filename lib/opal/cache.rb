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
      if RUBY_ENGINE == 'opal' || %w[1 true TRUE].include?(ENV['OPAL_CACHE'])
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

    class FileCache
      def initialize(dir: nil)
        @root = File.expand_path '..', Opal.gem_dir
        @dir = dir || find_dir
      end

      def fetch(*key)
        key = key.join('/')
        file = cache_filename_for(key)

        if File.exist?(file)
          load_data(file)
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
      end

      private def find_dir
        case
        when ENV['OPAL_CACHE_DIR']
          dir = ENV['OPAL_CACHE_DIR']
          FileUtils.mkdir_p(dir)
          dir
        when File.writable?(@root)
          dir = "#{@root}/tmp/cache"
          FileUtils.mkdir_p(dir)
          dir
        when File.writable?('/tmp') && File.sticky?('/tmp')
          dir = "/tmp/opal-cache-#{ENV['USER']}"
          FileUtils.mkdir_p(dir)
          FileUtils.chmod(0o700, dir)
          dir
        else
          raise CacheError, "Can't find a reliable cache directory"
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
        @runtime_hash ||= begin
          # We want to ensure the compiler and any Gemfile/gemspec (for development) stays untouched
          files = Dir["#{@root}/{Gemfile*,*.gemspec,lib/**/*}"]

          digest [
            files.sort.map { |f| File.mtime(f).to_f.to_s },
            Opal::Config.compiler_options.inspect,
          ].join('/')
        end
      end
    end
  end
end
