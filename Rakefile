require 'bundler'
Bundler.require
Bundler::GemHelper.install_tasks

import 'tasks/mspec.rake'

namespace :github do
  desc "Upload assets to github"
  task :upload_assets do
    require 'octokit'
    # https://github.com/octokit/octokit.rb#oauth-access-tokens
    token_path = '.github_access_token'
    File.exist?(token_path) or raise ArgumentError, "Please create a personal access token (https://github.com/settings/tokens/new) and paste it inside #{token_path.inspect}"
    token = File.read(token_path).strip
    client = Octokit::Client.new :access_token => token
    tag_name = ENV['TAG'] || raise(ArgumentError, 'missing the TAG env variable (e.g. TAG=v0.4.4)')
    release = client.releases('opal/opal').find{|r| p(r.id); p(r).tag_name == tag_name}
    release_url = "https://api.github.com/repos/opal/opal/releases/#{release.id}"
    %w[opal opal-parser].each do |name|
      client.upload_asset release_url, "build/#{name}.js", :content_type => 'application/x-javascript'
      client.upload_asset release_url, "build/#{name}.min.js", :content_type => 'application/x-javascript'
      client.upload_asset release_url, "build/#{name}.min.js.gz", :content_type => 'application/octet-stream'
    end
  end
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:mri_spec) do |t|
  t.pattern = 'mri_spec/**/*_spec.rb'
end

desc "Run tests through mspec"
task :mspec do
  RunSpec.new
end

task :default => [:mri_spec, :mspec] do
end

desc "Build specs to build/specs.js and build/specs.min.js"
task :build_specs do
  Opal::Processor.arity_check_enabled = true
  ENV['OPAL_SPEC'] = ["#{Dir.pwd}/spec/"].join(',')

  env = SpecEnvironment.new
  env.build
end

desc "Build opal.js and opal-parser.js to build/"
task :dist do
  Opal::Processor.arity_check_enabled = false
  Opal::Processor.const_missing_enabled = false

  env = Opal::Environment.new

  Dir.mkdir 'build' unless File.directory? 'build'

  %w[opal opal-parser].each do |lib|
    puts "* building #{lib}..."

    src = env[lib].to_s
    min = uglify src
    gzp = gzip min

    File.open("build/#{lib}.js", 'w+')        { |f| f << src }
    File.open("build/#{lib}.min.js", 'w+')    { |f| f << min } if min
    File.open("build/#{lib}.min.js.gz", 'w+') { |f| f << gzp } if gzp

    print "done. (development: #{src.size}B"
    print ", minified: #{min.size}B" if min
    print ", gzipped: #{gzp.size}Bx"  if gzp
    puts  ")."
    puts
  end
end

desc "Rebuild grammar.rb for opal parser"
task :racc do
  %x(racc -l lib/opal/grammar.y -o lib/opal/grammar.rb)
end

# Used for uglifying source to minify
def uglify(str)
  IO.popen('uglifyjs', 'r+') do |i|
    i.puts str
    i.close_write
    return i.read
  end
rescue Errno::ENOENT
  $stderr.puts '"uglifyjs" command not found (install with: "npm install -g uglify-js")'
  nil
end

# Gzip code to check file size
def gzip(str)
  IO.popen('gzip -f', 'r+') do |i|
    i.puts str
    i.close_write
    return i.read
  end
rescue Errno::ENOENT
  $stderr.puts '"gzip" command not found, it is required to produce the .gz version'
  nil
end
