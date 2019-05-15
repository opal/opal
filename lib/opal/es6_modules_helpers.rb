# frozen_string_literal: true

require 'pathname'

module Opal
  class ES6ModulesHelpers
    class << self
      def generate_import_name(module_name)
        # in ruby its legal to require the same module several times, in webpack es6 importing the same module only works, if the import name
        # is different, using the same import will result in a error.
        # As large ruby projects tend to require the same module in a context several times, the import name must be different
        # for each import. here a random import name is generated. webpack will make sure, that the code the different imports refer to,
        # is imported only once
        # generate random import name for a ruby module_name. Also replaces some characters that are illegal in JS import names.
        module_name.gsub('.', '_o_').gsub('@', '_at_').gsub(/\W/, '_') + rand(36**8).to_s(36)
      end

      def generate_file_import(module_name)
        # modules should have the ending .rb for imports, so that the opal-webpack-resolver-plugin
        # or the opal-webpack-loader don't mix them up with javascript imports
        # that is just a sensible convention for example, a require 'react', without ending:
        #   import 'react';  --> resolves to react.js in javascript space, may be resolved by webpack otherwise
        # vs. with ending:
        #   import 'react.rb';  --> resolves to react.rb in the opal/ruby space which gets transpiled to js by the loader
        # if a javascript file gets required as:
        #   require 'runtime'
        # it gets imported like so:
        #   import 'runtime.rb'
        # the opal-webpack-resolver-plugin will then check for a runtime.rb, but also for a runtime.js if the runtime.rb is not found.
        import_lines = []
        module_name_s = module_name.to_s
        module_name_s += '.rb' unless module_name_s.end_with?('.rb', '.js')
        import_name = generate_import_name(module_name_s)
        import_lines << "import #{import_name} from '#{module_name_s}';\n"
        import_lines << "if (typeof global.Opal.modules[#{module_name_s.inspect}] === 'undefined') {\n"
        import_lines << "  if (typeof #{import_name} === 'function') { #{import_name}(); }\n"
        import_lines << "}\n"
        import_lines
      end

      def generate_directory_imports(module_dir, module_path = nil)
        # recursively walk a directory and generate import lines for all .rb/.js files
        import_lines = []
        module_dir = determine_real_module_dir(module_dir)
        directory_path = if module_path
                           Pathname.new(File.join(module_dir.to_s, module_path.to_s)).expand_path
                         else
                           module_dir.expand_path
                         end
        directory_path.each_child do |child_path|
          if child_path.directory?
            import_lines << generate_directory_imports(child_path)
          elsif child_path.file?
            import_lines += generate_file_import(determine_real_module_name(child_path.to_s))
          end
        end
        import_lines
      end

      def generate_module_import(module_path)
        import_lines = []
        real_module_name = determine_real_module_name(module_path)
        import_name = generate_import_name(module_path)
        has_extension = module_path.end_with?('.js', '.rb')
        import_lines << "import #{import_name} from '#{module_path}#{'.rb' unless has_extension}';\n"
        unless module_path == 'corelib/runtime'
          # webpack replaces module_import_name with a function, but
          # during bootstrapping on the client, when the imports are imported, for a circular import
          # module_import_name is just a object, because the outer module_import_name() did not finish execution and thus
          # the result of the webpack function looking up module_import_name is not a function yet.
          # once the import returned, the result of the webpack function looking up module_import_name will be a function.
          # checking if module_import_name actually is a function will make the bootstrapping work,
          # at this time the module_import_name has not been imported into local context, luckily the opal require happens
          # later in time, after all the imports, then Opal.modules is filled correctly and the opal require
          # can be resolved
          #
          # This behaviour is needed for all modules, except corelib/runtime!
          import_lines << "if (typeof global.Opal.modules[#{real_module_name.inspect}] === 'undefined') {\n"
          import_lines << "  if (typeof #{import_name} === 'function') { #{import_name}(); }\n"
          import_lines << "}\n"
        end
        import_lines
      end

      def determine_real_module_name(module_path)
        if module_path.start_with?('/')
          module_path + '.rb' unless module_path.end_with?('.rb')
        elsif module_path.start_with?('.')
          determine_real_module_name(Pathname.new(module_path).expand_path.to_s)
        elsif module_path.end_with?('.js')
          module_path.sub(/\.js\z/, '')
        else
          module_path
        end
      end

      def determine_real_module_dir(module_dir)
        module_dir_s = module_dir.to_s
        return module_dir.expand_path if module_dir_s == '.'
        return module_dir if module_dir.absolute?
        if module_dir_s.start_with?('..') || module_dir_s.start_with?('./')
          return module_dir.expand_path
        else
          Opal.paths.each do |path|
            new_module_dir = File.join(path, module_dir_s)
            return Pathname.new(new_module_dir) if Dir.exist?(new_module_dir)
          end
        end
      end

      def module_name_for_pwd(original_path_s)
        pwd = Dir.pwd
        if original_path_s.start_with?(pwd)
          # got a match in current dir
          # remove current dir at the beginning and the filename extension to get the module name like 'some/ruby'
          return original_path_s[(pwd.size + 1)..-1].sub(/\.(js|rb|js\.rb)\z/, '')
        else
          # no match at all, return original path
          return original_path_s
        end
      end

      def module_name_from_paths_helper(path, original_path_s)
        # split the filename_path into path and basename, only the path is needed and compared against Opal.paths
        path, _basename = path.split # Pathname#split that is and doesn't accept args
        path_s = path.expand_path.to_s
        if Opal.paths.include?(path_s)
          # got a load path match
          # remove known load path at the beginning and the filename extension to get the module name like 'some/ruby'
          return original_path_s[(path_s.size + 1)..-1].sub(/\.(js|rb|js\.rb)\z/, '')
        end
        if path.root?
          # no match in Opal.paths, check pwd
          return module_name_for_pwd(original_path_s)
        end
        module_name_from_paths_helper(path, original_path_s)
      end
    end
  end
end
