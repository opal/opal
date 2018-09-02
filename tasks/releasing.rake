require 'bundler'
Bundler.require
Bundler::GemHelper.install_tasks

# Let the release process update the changelog from github
task :release => :changelog

desc "Update CHANGELOG.md usign info from published GitHub releases (the first unreleased section is preserved)"
task :changelog do
  changelog_path    = "#{__dir__}/../CHANGELOG.md"
  splitter          = '<!-- generated-content-beyond-this-comment -->'
  changelog_entries = []

  require 'date'
  require 'octokit'
  Octokit.auto_paginate = true

  releases = Octokit.releases('opal/opal').sort_by do |r|
    Gem::Version.new(r[:tag_name][1..-1])
  end.select do |release|
    release[:tag_name] =~ /^v(\d+)(\.\d+)*$/
  end

  previous_tag_name = '000000'
  releases.each do |release|
    tag_name = release[:tag_name]
    release_date = release[:created_at].to_date.iso8601 # YYYY-MM-DD
    compare_url = "https://github.com/opal/opal/compare/#{previous_tag_name}...#{tag_name}"
    changelog_entry = [
      "## [#{tag_name[1..-1]}](#{compare_url}) - #{release_date}\n\n\n",
      release[:body].gsub("\r\n", "\n").strip,
    ].join('')

    changelog_entries.unshift changelog_entry
    previous_tag_name = tag_name
  end

  heading_and_unreleased = File.read(changelog_path).split(splitter, 2).first.strip

  changelog_entries.unshift heading_and_unreleased+"\n"+splitter
  changelog_entries << nil # for the final newlines

  File.write changelog_path, changelog_entries.join("\n\n\n\n\n")
end
