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
