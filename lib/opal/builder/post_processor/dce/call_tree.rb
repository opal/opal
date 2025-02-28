# frozen_string_literal: true

# rubocop:disable Style/CaseEquality

module Opal
  class Builder
    class PostProcessor
      class DCE < PostProcessor
        # CallTree records a tree of definitions and calls, like
        # so:
        #
        # (root):
        # - definitions:
        #   - CallTree:
        #       calls: attr_accessor
        #       definitions:
        #         - initialize
        #             calls: Set, new
        #
        # After collecting, this structure is later used by
        # ShadowingCallTree to calculate which parts of the
        # code can be safely stripped.
        class CallTree
          attr_accessor :definitions, :calls

          def initialize(loc = :"")
            @loc = loc
            @definitions = {}
            @calls = Set.new
          end

          def dig(*path)
            if path.empty?
              [self]
            else
              first, *rest = *path
              Array(first).flat_map do |leaf|
                self[leaf].dig(*rest)
              end
            end
          end

          def add_calls(calls, path = [])
            if path.empty?
              @calls += Array(calls)
            else
              dig(*path).each do |leaf|
                leaf.add_calls(calls)
              end
            end
          end

          def add_definitions(path = [])
            *rest, last = *path
            if rest.empty?
              Array(last).each do |leaf|
                @definitions[leaf] ||= CallTree.new(:"#{@loc}/#{leaf}")
              end
            else
              dig(*rest).each do |leaf|
                leaf.add_definitions([last])
              end
            end
          end

          def [](child)
            @definitions[child]
          end
        end

        # Hides access to parts of the structure that is meant
        # to be stripped, so that multiple passes of DCE can be
        # performed, but only on the unstripped parts.
        #
        # This class also contains the logic
        class ShadowedCallTree
          def initialize(call_tree)
            @shadowed = Set.new
            @call_tree = call_tree
          end

          def shadow(items)
            @shadowed += Array(items)
          end

          def shadowed?(key)
            @shadowed.include?(key)
          end

          def in_temporary_shadowing_context
            old_shadowed = @shadowed
            ret = yield
            @shadowed = old_shadowed
            ret
          end

          def inspect(call_tree = @call_tree, indent = 1, shadowed = false)
            indent_str = '  ' * indent
            newline = "\n"
            calls_str = call_tree.calls.map(&:inspect).join(', ')
            calls_str + newline +
              call_tree.definitions.map do |k, v|
                is_shadowed = shadowed || shadowed?(k)
                inspect_str = inspect(v, indent + 1, is_shadowed)
                shadowed_str = is_shadowed ? '[S] ' : '[ ] '
                indent_str + shadowed_str + k.to_s + ': ' + inspect_str
              end.join
          end

          def dfs(call_tree = @call_tree, key = nil, &block)
            yield(call_tree, key)
            call_tree.definitions.each do |subkey, value|
              next if shadowed? subkey
              dfs(value, subkey, &block)
            end
          end

          def all_definitions
            defs = Set.new
            dfs { |_, key| defs << key }
            defs
          end

          def all_calls
            calls = Set.new
            dfs { |node, _| calls += node.calls }
            calls
          end

          def calls_by_key
            by_key = Hash.new { |a, b| a[b] = [] }
            dfs { |node, key| by_key[key] << node }
            by_key.transform_values do |value|
              value.map(&:calls).sum(Set.new)
            end
          end

          def all_calls_from_root
            by_key = calls_by_key

            final_calls = Set.new
            calls = by_key[nil].to_a
            while (call = calls.pop)
              next if final_calls.include?(call)
              final_calls << call
              calls += by_key[call].to_a
            end
            final_calls
          end

          def unused_definitions
            definitions = all_definitions
            used_calls = all_calls_from_root
            matcher_calls = used_calls.reject { |i| i.is_a?(Symbol) }
            definitions -= used_calls
            definitions.reject do |definition|
              matcher_calls.any? { |matcher| matcher === definition }
            end.to_set
          end

          def all_constant_definitions
            all_definitions.select { |key| key.to_s.match?(/\A[A-Z]/) }
          end

          # While undoubtedly very useful, Complex and Rational
          # can be stripped safely together.
          def enhanced_all_constant_definitions
            all_constant_definitions + [%i[Complex Rational]]
          end

          # An approach that allows us to strip a module if there's
          # no external usage of its constants by temporarily
          # shadowing each one, checking for any calls referencing it,
          # and then permanently shadowing (removing) it when it is
          # confirmed to be unused.
          def try_shadowing_constants
            enhanced_all_constant_definitions.each do |key|
              in_temporary_shadowing_context do
                shadow key
                shadow unused_definitions
                (all_calls & Array(key)).empty?
              end and shadow key
            end
          end

          def definition_count
            all_definitions.length
          end

          def process
            def_count = definition_count
            # Run steps repeatedly until there's nothing left to
            # remove.
            loop do
              shadow unused_definitions
              try_shadowing_constants

              old_def_count, def_count = def_count, definition_count
              break if def_count == old_def_count
            end

            @kept_definitions = all_definitions
          end

          def keep_definition?(name)
            @kept_definitions.include?(name)
          end
        end
      end
    end
  end
end

# rubocop:enable Style/CaseEquality
