# frozen_string_literal: true

if RUBY_ENGINE != 'opal'
  require 'digest'
end
require 'pathname'

module Opal
  class ES6ModulesHelpers
    module InstanceMethods
      def import_counter
        @import_counter ||= 0
        @import_counter += 1
      end

      def generate_import_name(module_path)
        # In ruby its legal to require the same module several times, in webpack es6 importing the same module only works, if the import name
        # is different, using the same import will result in a error.
        # As large ruby projects tend to require the same module in a context several times, the import name must be different
        # for each import. Here the import name is generated as MD5 hash from module_path and compiler.file, plus a counter,
        # just to make sure if a module gets imported several times from the current file, to differentiate the imports.
        # webpack will make sure, that the code the different imports refer to, is imported only once.
        if RUBY_ENGINE != 'opal'
          "O_#{Digest::MD5.hexdigest("#{module_path}_#{compiler.file}")}_#{import_counter}"
        else
          # if running in opal, 'digest' is not available, so we don't calculate the MD5 hash, but instead just use
          # the module_path and compiler.file and make sure it has no illegal characters in it, plus the counter.
          "#{module_path}_#{compiler.file}".gsub('.', '_o_').gsub('@', '_at_').gsub(/\W/, '_') + '_' + import_counter.to_s
        end
      end

      def generate_directory_imports(base_dir, tree_path = nil)
        # recursively walk a directory and generate import lines for all .rb/.js files
        import_lines = []
        base_dir = determine_real_module_dir(base_dir)
        directory_path = if tree_path
                           Pathname.new(File.join(base_dir.to_s, tree_path.to_s)).expand_path
                         else
                           base_dir.expand_path
                         end
        directory_path.each_child do |child_path|
          next if child_path.basename.to_s.start_with?('.')
          if child_path.directory?
            import_lines << generate_directory_imports(child_path.expand_path)
          elsif child_path.file?
            import_lines += generate_module_import(child_path.expand_path.to_s)
          end
        end
        import_lines
      end

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
      def generate_module_import(ruby_module_path)
        # module_path is empty for: require File.expand_path(o), can't generate a import, let it be resolved at runtime
        return [''] if ruby_module_path.empty?
        import_lines = []
        ruby_module_path = determine_real_module_path(ruby_module_path)
        import_module_name, ruby_module_name = Opal::ES6ModulesHelpers.module_names_from_paths(Pathname.new(ruby_module_path), ruby_module_path)
        import_name = generate_import_name(import_module_name)
        import_lines << "import #{import_name} from '#{import_module_name}';\n"
        unless ruby_module_name == 'corelib/runtime'
          import_lines << "if (typeof global.Opal.modules['#{ruby_module_name}'] === 'undefined') {\n"
          import_lines << "  if (typeof #{import_name} === 'function') { #{import_name}(); }\n"
          import_lines << "}\n"
        end
        import_lines
      end

      def determine_real_module_path(module_path)
        module_path = module_path.to_s
        module_path += '.rb' unless module_path.end_with?('.rb', '.js')
        if module_path.start_with?('/')
          module_path
        elsif module_path.start_with?('.')
          return determine_real_module_path(Pathname.new(module_path).expand_path.to_s)
        else
          Opal.paths.each do |path|
            new_module_path = File.join(path, module_path)
            if File.exist?(new_module_path)
              module_path = new_module_path
              break
            end
          end
        end
        Pathname.new(module_path).expand_path.to_s
      end

      def determine_real_module_dir(module_dir)
        module_dir_s = module_dir.to_s
        return module_dir.expand_path if module_dir_s == '.'
        return module_dir if module_dir.absolute?
        if module_dir_s.start_with?('..', './')
          return module_dir.expand_path
        else
          Opal.paths.each do |path|
            new_module_dir = File.join(path, module_dir_s)
            if Dir.exist?(new_module_dir)
              module_dir = Pathname.new(new_module_dir).expand_path
              break
            end
          end
          module_dir
        end
      end
    end

    class << self
      def module_names_from_module_paths(original_path, current_path)
        # remove known load path at the beginning and the filename extension to get the module name like 'some/ruby'
        module_name = original_path[(current_path.size + 1)..-1]
        [module_name.end_with?('.rb') ? module_name : module_name + '.rb', module_name.sub(/\.(js|rb|js\.rb)\z/, '')]
      end

      def module_names_for_pwd(original_path_s)
        pwd = Dir.pwd
        if original_path_s.start_with?(pwd)
          # got a match in current dir
          module_names_from_module_paths(original_path_s, pwd)
        else
          # no match at all, return original path
          [original_path_s, original_path_s]
        end
      end

      def module_names_from_paths(path, original_path_s)
        # split the filename_path into path and basename, only the path is needed and compared against Opal.paths
        path, _basename = path.split # Pathname#split that is and doesn't accept args
        path_s = path.expand_path.to_s
        if Opal.paths.include?(path_s) && path_s.size > 1
          # got a load path match
          return module_names_from_module_paths(original_path_s, path_s)
        end
        if path.root?
          # no match in Opal.paths, check pwd
          return module_names_for_pwd(original_path_s)
        end
        module_names_from_paths(path, original_path_s)
      end
    end
  end
end
