module Opal
  module Sprockets

    class PathReader
      def initialize(env, context)
        @env ||= env
        @context ||= context
      end

      def read path
        if path.end_with? '.js'
          context.depend_on_asset(path)
          env[path].to_s
        else
          context.depend_on(path)
          File.read(expand(path))
        end
      rescue ::Sprockets::FileNotFound
        nil
      end

      def depend_on(path)
        context.depend_on path
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
