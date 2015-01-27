module Opal
  module Sprockets

    class PathReader
      def initialize(env, context)
        @env ||= env
        @context ||= context
      end

      def read path
        if path.end_with? '.js'
          env[path].to_s
        else
          File.read(expand(path))
        end
      rescue ::Sprockets::FileNotFound
        nil
      end

      def stat path
        File.stat expand(path)
      rescue Errno::ENOENT
        nil
      end

      def expand path
        env.resolve(path)
      end

      def paths
        env.paths
      end

      attr_reader :env, :context
    end

  end
end
