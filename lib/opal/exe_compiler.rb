# frozen_string_literal: true

require 'fileutils'
require 'tmpdir'
require 'opal/os'

module Opal
  class ExeCompiler
    RUNTIMES = -> {
      types = %w[bun deno node quickjs]
      types.freeze
    }.call

    def self.compile_exe(type, src_out)
      new(type, src_out).compile_exe
    end

    def initialize(type, src_out)
      raise "Cannot compile exe: unsupported runtime type '#{type}'" unless RUNTIMES.include?(type)
      if src_out.instance_of?(IO)
        @out_path = "opal_#{type}_exe"
      elsif src_out.is_a?(File)
        @out_path = src_out.path
      else
        raise 'Cannot compile exe: source must be a file.'
      end
      @type, @source = type, src_out
    end

    def compile_exe
      puts "Creating #{@out_path}:"
      res = true
      Dir.mktmpdir('opal-compile-exe-') do |dir|
        src_path = File.join(dir, "#{File.basename(@out_path)}.js")
        @source.flush
        @source.fsync
        @source.close
        File.write(src_path, File.read(@source.path))
        File.unlink(@source.path)
        res = send("compile_#{@type}_exe".to_sym, src_path, dir)
      end
      puts 'Done.'
      res ? 0 : 1
    end

    private

    def append_exe_to_out_path_on_windows
      if OS.windows? && !@out_path.downcase.end_with?('.exe')
        @out_path << '.exe'
      end
    end

    def compile_bun_exe(src_path, _dir)
      system('bun', 'build', src_path, '--compile', '--outfile', @out_path)
    end

    def compile_deno_exe(src_path, _dir)
      system('deno', 'compile',
             '--allow-env',
             '--allow-read',
             '--allow-sys',
             '--allow-write',
             '--output', @out_path, src_path
            )
    end

    def compile_node_exe(src_path, dir)
      # Very new, experimental and complicated.
      # See https://nodejs.org/api/single-executable-applications.html
      Dir.chdir(dir) do
        # 1. Create a JavaScript file - already done above
        # 2. Create a configureation file
        File.write('sea-config.json', "{\"main\":\"#{src_path}\",\"output\":\"sea-prep.blob\"}")
        # 3. Generate the blob to be injected:
        system('node', '--experimental-sea-config', 'sea-config.json')
        # 4. Create a copy of the node executable
        # What could possibly go wrong?
        system('node', '-e', 'require("node:fs").copyFileSync(process.execPath, "node_copy.exe")')
        # 4.1. Adjust file permissions
        File.chmod(0o775, 'node_copy.exe')
        # 5. Remove the signature of the binary
        if OS.macos?
          system('codesign --remove-signature node_copy.exe')
        elsif OS.windows?
          system('signtool remove /s node_copy.exe')
        end
        # 6. Inject the blob into the copied binary
        if OS.macos?
          system('npx', 'postject', 'node_copy.exe', 'NODE_SEA_BLOB', 'sea-prep.blob',
                 '--sentinel-fuse', 'NODE_SEA_FUSE_fce680ab2cc467b6e072b8b5df1996b2',
                 '--macho-segment-name', 'NODE_SEA' # Thats not a 'macho', thats Mach-O, the Mach Object File Format
                )
        else
          system('npx', 'postject', 'node_copy.exe', 'NODE_SEA_BLOB', 'sea-prep.blob',
                 '--sentinel-fuse', 'NODE_SEA_FUSE_fce680ab2cc467b6e072b8b5df1996b2'
                )
        end
        # 7. Sign the binary
        if OS.macos?
          system('codesign --sign - node_copy.exe')
        elsif OS.windows?
          system('signtool sign /fd SHA256 node_copy.exe')
        end
      end
      # 8. Copy binary to target
      append_exe_to_out_path_on_windows
      FileUtils.cp(File.join(dir, 'node_copy.exe'), @out_path)
      true
    end

    def compile_quickjs_exe(src_path, _dir)
      append_exe_to_out_path_on_windows
      # '-flto', '-fbignum' might be useful options, depending on quickjs version/build
      system('qjsc', '-o', @out_path, src_path)
    end
  end
end
