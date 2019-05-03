# frozen_string_literal: true

require 'pathname'

module Opal
  class ES6ModulesHelpers
    def self.generate_import_name(module_name)
      # in ruby its legal to require the same module several times, in webpack es6 importing the same module only works, if the import name
      # is different, using the same import will result in a error.
      # As large ruby projects tend to require the same module in a context several times, the import name must be different
      # for each import. here a random import name is generated. webpack will make sure, that the code the different imports refer to,
      # is imported only once
      # generate random import name for a ruby module_name. Also replaces some characters that are illegal in JS import names.
      module_name.gsub('.', 'o_').tr('-', '_').tr('/', '_').gsub('@', '_at_') + rand(36**8).to_s(36)
    end

    def self.generate_file_import(child_path)
      import_lines = []
      path_s = child_path.basename.to_s
      if path_s.end_with?('.rb', '.js')
        module_path = child_path.expand_path.to_s[(base_dir.expand_path.to_s.length + 1)..-1].sub(/\.(js|rb)\z/, '')
        file_ending = '.' + path_s.split('.').last
        import_name = generate_import_name(module_path + file_ending)
        import_lines << "import #{import_name} from '#{module_path}#{file_ending}';\n"
        import_lines << "if (typeof Opal.modules[#{module_path.inspect}] === 'undefined') {\n"
        import_lines << "  if (typeof #{import_name} === 'function') { #{import_name}(); }\n"
        import_lines << "}\n"
        import_lines
      end
      import_lines
    end

    def self.generate_directory_imports(base_dir, module_path)
      # recursively walk a directory and generate import lines for all .rb/.js files
      import_lines = []
      directory_path = base_dir + module_path
      directory_path.each_child do |child_path|
        if child_path.directory?
          import_lines << generate_directory_imports(base_dir, child_path.expand_path.to_s[(base_dir.expand_path.to_s.length + 1)..-1])
        elsif child_path.file?
          import_lines += generate_file_import(child_path)
        end
      end
      import_lines
    end

    def self.generate_module_imports(module_path)
      real_module_name = determine_real_module_name(module_path)
      module_import_name = generate_import_name(module_path)
      module_import_lines = []
      has_extension = module_path.end_with?('.js', '.rb')
      module_import_lines << "import #{module_import_name} from '#{module_path}#{'.rb' unless has_extension}';\n"
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
        module_import_lines << "if (typeof global.Opal.modules[#{real_module_name.inspect}] === 'undefined') {\n"
        module_import_lines << "  if (typeof #{module_import_name} === 'function') { #{module_import_name}(); }\n"
        module_import_lines << "}\n"
      end
      module_import_lines
    end

    def self.determine_real_module_name(module_path)
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
      if module_path.start_with?('/')
        module_path_rb = module_path.end_with?('.rb') ? module_path : module_path + '.rb'
        Opal::Compiler.module_name_from_paths(module_path_rb)
      else
        module_path
      end
    end

    def self.module_name_for_pwd(original_path_s)
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

    def self.module_name_from_paths_helper(path, original_path_s)
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
