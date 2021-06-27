# frozen_string_literal: true

if RUBY_ENGINE != 'opal'
  require 'fileutils'
  require 'digest/sha2'
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
      def disabled?
        # In the future we may think about some kind of a compiler switch.
        !%w[1 true TRUE].include? ENV['OPAL_CACHE']
      end

      def find_key_or_exec(klass, *key, &block)
        if klass != Opal::BuilderProcessors::RubyProcessor || disabled?
          yield
        elsif File.exist?(file = cache_file_name(key))
          Marshal.load(File.binread(file))
        else
          compiler = yield
          File.binwrite(file, Marshal.dump(compiler))
          compiler
        end
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
        "#{cache_directory_name}/#{runtime_hash}-#{hash key}.rbm"
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
