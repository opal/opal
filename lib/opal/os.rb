# frozen_string_literal: true

require 'shellwords'

module Opal
  module OS
    module_function

    def windows?
      /bccwin|cygwin|djgpp|mingw|mswin|wince/.match?(RbConfig::CONFIG['host_os'])
    end

    def macos?
      /darwin|mac os/.match?(RbConfig::CONFIG['host_os'])
    end

    def shellescape(str)
      if windows?
        '"' + str.gsub('"', '""') + '"'
      else
        str.shellescape
      end
    end

    def env_sep
      windows? ? ';' : ':'
    end

    def path_sep
      windows? ? '\\' : '/'
    end

    def cmd_sep
      windows? ? ' & ' : ' ; '
    end

    def dev_null
      windows? ? 'NUL' : '/dev/null'
    end

    def bash_c(*commands)
      cmd = if windows?
              [
                'bundle',
                'exec',
                'cmd',
                '/c',
              ]
            else
              [
                'bundle',
                'exec',
                'bash',
                '-c',
              ]
            end

      cmd << commands.join(cmd_sep)
    end
  end
end
