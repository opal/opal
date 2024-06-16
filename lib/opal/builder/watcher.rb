module Opal
  class Builder
    module Watcher
      # Builds and watches all paths for changes and then rebuilds, does not return
      def watch
        loop do
          changes = updates
          if changes[:modified].any? || changes[:added].any? || changes[:removed].any?
            yield self, changes
          end
          sleep 0.5
        end
      end

      # Return the updates in the paths since last build
      def updates
        current_build_time = Time.now
        changes = { added: [], modified: [], removed: [] }
        directories = {}
        pwd = Dir.pwd
        last_build_time = build_time

        # check processed files
        processed.dup.each do |asset|
          case asset.changed?
          when :removed
            changes[:removed] << asset
            processed.delete(asset)
          when :modified
            asset_count = processed.length
            changes[:modified] << update(asset)
            if processed.size != asset_count
              added_assets = processed.pop(processed.size - asset_count)
              # If assets have been added by require_tree
              # ensure they are inserted before current asset.
              processed.insert(processed.index(asset), *added_assets)
              changes[:added].concat(added_assets)
            end
            add_to_directories(directories, asset)
          else
            add_to_directories(directories, asset)
          end
        end

        # check for added files
        directories.each do |dir, processed_entries|
          if dir.start_with?(pwd) # only check project directories
            current_entries = []
            Dir.each_child(dir) do |entry|
              current_entries << entry unless Dir.exist?(File.join(dir, entry))
            end
            (current_entries - processed_entries).each do |path|
              abs_path = File.join(dir, path)
              if File::Stat.new(abs_path).mtime > last_build_time # ignore files that existed before the last build
                # check if asset has already been added by require_tree above
                unless changes[:added].index { |ast| ast.abs_path == abs_path }
                  asset_count = processed.length
                  changes[:added] << build_str(source_for(abs_path), path)
                  if processed.length > (asset_count + 1)
                    changes[:added].concat(processed[asset_count..-1])
                  end
                end
              end
            end
          end
        end

        # #build is called multiple times above, with each call setting the build_time.
        # If files are added in between to a directory, that has already been processed,
        # they may get skipped, because their mtime may be earlier than the last build_time.
        # Ensure build_time is set to the time #update was called first, so that the files
        # that may have been added in between #build calls above, are processed with
        # the next call to #update.
        build_time = current_build_time

        changes
      rescue StandardError, Opal::SyntaxError => e
        $stderr.puts "Opal::Builder rebuilding failed: #{e.message}"
        changes[:error] = e
        changes
      end

      private

      def update(asset)
        asset.update(source_for(asset.abs_path))
        requires = preload + asset.requires + tree_requires(asset, asset.abs_path)
        # Don't automatically load modules required by the module
        process_requires(asset.filename, requires, asset.autoloads, asset.options)
        # TODO: the order corrector may be required here
        asset
      end

      def add_to_directories(directories, asset)
        return unless asset.abs_path
        dirname = File.dirname(asset.abs_path)
        directories[dirname] = [] unless directories.key?(dirname)
        directories[dirname] << File.basename(asset.abs_path)
      end
    end
  end
end
