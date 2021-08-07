# frozen_string_literal: true

if RUBY_ENGINE != 'opal'
  require 'fileutils'
  require 'digest/sha2'
  require 'zlib'
end

module Opal
  module Cache
    module_function

    class CacheError < StandardError; end

    if RUBY_ENGINE == 'opal'
      def find_key_or_exec(*, &block)
        yield
      end
    else
      SHARED_ENV = Ractor.make_shareable(ENV.to_h)

      def disabled?
        # In the future we may think about some kind of a compiler switch.
        !%w[1 true TRUE].include? SHARED_ENV['OPAL_CACHE']
      end

      def find_key_or_exec(klass, *key, &block)
        if klass != Opal::BuilderProcessors::RubyProcessor || disabled?
          yield
        elsif File.exist?(file = cache_file_name(key))
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
        out = File.binread(file)
        out = Zlib.gunzip(out)
        out = Marshal.load(out)
      end

      private def cache_directory_name
        @cache_directory_name ||= begin
          # Is our Opal directory writable?
          if File.writable?(dir = __dir__ + '/../..')
            FileUtils.mkdir_p(dir += '/tmp/cache')
          elsif File.writable?(dir = '/tmp') && File.sticky?(dir)
            FileUtils.mkdir_p(dir += "/opal-cache-#{ENV['USER']}")
            FileUtils.chmod(0o700, dir)
          else
            raise CacheError, "Can't find a reliable cache directory"
          end

          dir
        end
      end

      private def cache_file_name(key)
        "#{cache_directory_name}/#{runtime_hash}-#{hash key}.rbm.gz"
      end

      private def hash(object)
        digest object.inspect
      end

      private def digest(string)
        Digest::SHA256.hexdigest(string)[-32..-1].to_i(16).to_s(36)
      end

      private def runtime_hash
        @runtime_hash ||= begin
          # We want to ensure the compiler stays untouched
          files = Dir[__dir__ + '/../../lib/**/*']
          # Along with our Gemfiles
          files += Dir[__dir__ + '/../../Gemfile*']
          files += Dir[__dir__ + '/../../*.gemspec']

          str = files.map { |i| File.mtime(i).to_f.to_s }.join(',')

          # Add Opal::Config
          str << hash(Opal::Config.compiler_options)

          # Compute our hash
          digest str
        end
      end
    end
  end
end
