# backtick_javascript: true
# helpers: hash_each

module ::Opal
  module JS
    class << self
      def project_args(args, block, spec, kwargs_mode, name)
        if spec.nil?
          return args if block.nil? || `block == null`

          return args + [block]
        end

        has_block = !block.nil? && `block != null`
        positional = args.dup
        kwargs = nil

        if positional.last.is_a?(::Hash)
          kwargs = positional.pop
        end

        if !kwargs.nil? && !spec.include?(:**)
          raise ::ArgumentError, "keyword arguments are not projected for JS method `#{name}'"
        end

        if has_block && !spec.include?(:&)
          raise ::ArgumentError, "block is not projected for JS method `#{name}'"
        end

        consumed = []
        result = []

        # Integer tokens must be reserved before :* expands remaining arguments.
        spec.each do |token|
          next unless token.is_a?(::Integer)

          index = token < 0 ? positional.length + token : token
          if index < 0 || index >= positional.length
            raise ::ArgumentError, "missing argument index #{token} for JS method `#{name}'"
          end

          consumed << index
        end

        spec.each do |token| # rubocop:disable Style/CombinableLoops
          case token
          when :*
            positional.each_with_index do |value, index|
              result << value unless consumed.include?(index)
            end
          when :**
            result << convert_kwargs(kwargs || {}, kwargs_mode)
          when :&
            result << block if has_block
          when ::Integer
            index = token < 0 ? positional.length + token : token
            result << positional[index]
          else
            raise ::ArgumentError, "unsupported JS argument projection token `#{token.inspect}'"
          end
        end

        result
      end

      def convert_kwargs(hash, mode)
        return hash unless mode == :convert

        %x{
          var result = {}, source = hash;
          $hash_each(source, false, function(key, value) {
            result[#{camelize(`key`)}] = #{to_js(`value`)};
            return [false, false];
          });
          return #{from_js(`result`)};
        }
      end
    end
  end
end
