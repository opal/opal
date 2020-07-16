namespace :packages do
  copy_to = ->(build_dir, dirs) do
    dirs.each do |dir|
      cd dir do
        FileUtils.cp_r "*", build_dir
      end
    end
  end
  precompile = ->(build_dir, files) do
    require 'opal/util'
    require 'opal/config'
    require 'json'

    Opal::Config.arity_check_enabled = true
    Opal::Config.const_missing_enabled = true
    Opal::Config.dynamic_require_severity = :warning
    Opal::Config.missing_require_severity = :error

    mkdir_p build_dir unless File.directory? build_dir

    files.map do |file|
      Thread.new {
        Thread.current.abort_on_exception = true

        # Set requirable to true, unless building opal. This allows opal to be auto-loaded.
        builder = Opal::Builder.build(file, requirable: true)

        builder.processed.map do |asset|
          print '.'
          lib = asset.filename.sub(%r{^\./}, '')

          lib = lib.sub(%r{(\.js)?(\.rb)?$}, '')
          imports = asset.requires.map do |require|
            dirname = File.dirname(lib)
            if dirname == '.'
              expanded = require
            else
              expanded = File.join(dirname.gsub(%r{[^/]+}, '..'), require)
            end
            p lib => {require => expanded}
            "require('#{expanded}');"
          end

          src = imports.join + asset.source.to_s + "\n//# sourceMappingURL=./#{lib}.map\n"

          FileUtils.mkpath("#{build_dir}/#{File.dirname(lib)}")
          File.write("#{build_dir}/#{lib}.js", src)
          File.write("#{build_dir}/#{lib}.map", asset.source_map.to_json)
        end
      }
    end.map(&:value)
  end

  update_version = ->(package_dir) {
    require 'opal/version'
    require 'pathname'
    require 'json'
    package = JSON.parse(Pathname(package_dir).join('package.json').read)
    package["version"] = Opal::VERSION + '-alpha.1'
    File.write('package.json', JSON.pretty_generate(package))
  }

  task :corelib do
    require 'opal'
    path = File.expand_path(Opal.core_dir)
    files = Dir.chdir(path) do
      Dir['**/*.rb'].map { |lib| lib.sub(%r{^(.*)\.rb$}, '\1') }
    end.sort
    puts files
    precompile["packages/@opal/corelib/dist", files]

    index_requires = files.map do |file|
      "require('./dist/#{file}')"
    end
    File.write "packages/@opal/corelib/index.js", <<~JS
      require('./dist/corelib/runtime')

      #{index_requires.join("\n")}

      module.exports = Opal
    JS
    puts
  end

  task :stdlib do
    require 'opal'
    path = File.expand_path(Opal.std_dir)
    files = Dir.chdir(path) do
      Dir['**/*.rb'].map { |lib| lib.sub(%r{^(.*)\.rb$}, '\1') }
    end.sort
    puts files
    precompile["packages/@opal/stdlib/dist", files]

    index_requires = files.map do |file|
      "require('./dist/#{file}')"
    end
    File.write "packages/@opal/stdlib/index.js", <<~JS
      #{index_requires.join("\n")}

      module.exports = Opal
    JS
    puts
  end
end

task 'packages' => 'packages:build'
