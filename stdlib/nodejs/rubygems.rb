require 'json'

module Gem
  class Install
    def initialize(name, version)
      @name = name
      @version = version
    end

    def version
      @version ||= latest_version(name)
    end

    def latest_version(name)
      command = curl("https://rubygems.org/api/v1/versions/#{name}.json")
      versions = JSON.parse system(command)
      versions.first['number']
    end

    def full_name
      "#{name}-#{version}"
    end

    def gem_home
      ENV['HOME']+'/.opal-node/opal-gems/#{RUBY_ENGINE_VERSION}'
    end

    def gems_dir
      File.join(gem_home, :gems)
    end

    def specs_dir
      File.join(gem_home, :specs)
    end

    def perform
      gem_dir = File.join(gems_dir, full_name)
      spec_dir = File.join(specs_dir, full_name+'.yml')
      system "mkdir -p #{gem_dir} #{spec_dir}"

      Dir.chdir gem_dir do
        system curl("https://rubygems.org/downloads/#{name}-#{version}.gem") + '| tar -xv'
        system "gunzip metadata.gz --stdout > #{specs_dir}/#{full_name}.yml"
        system "gunzip data.tar.gz"
        system "tar -xvf data.tar"
      end
    end

    def curl url
      "curl -L #{url}"
    end
  end
end

command = ARGV.shift
case command
when 'install'
  name = ARGV.shift
  if ARGV.include? '-v'
    version = ARGV[ ARGV.index('-v')+1 ]
  else
    version = nil
  end
  install = Gem::Install.new(name, version)
  install.perform
else
  raise NotImplementedError, "sorry, the #{command.inspect} is not implemented."
end
