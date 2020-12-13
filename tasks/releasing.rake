# frozen_string_literal: true

require 'bundler'
Bundler.require
Bundler::GemHelper.install_tasks

# Let the release process update the changelog from github
task :release => :changelog

github_releases = -> do
  require 'date'
  require 'octokit'
  Octokit.auto_paginate = true

  Octokit.releases('opal/opal').sort_by do |r|
    Gem::Version.new(r[:tag_name][1..-1])
  end.select do |release|
    release[:tag_name] =~ /^v(\d+)(\.\d+)*$/
  end
end

expand_pull_request_links = -> string {
  string.gsub(/\(#(\d+)\)/, '([#\1](https://github.com/opal/opal/pull/\1))')
}

changelog_entry = -> (
  tag_name:,
  release_date:,
  previous_tag_name:,
  body:
) do
  compare_url = "https://github.com/opal/opal/compare/#{previous_tag_name}...#{tag_name}"
  version_name = tag_name == 'HEAD' ? 'Unreleased' : tag_name.sub(/^v/, '')
  [
    "## [#{version_name}](#{compare_url}) - #{release_date}\n\n\n",
    expand_pull_request_links[body.gsub("\r\n", "\n").strip],
  ].join('')
end

CHANGELOG_HEADING = <<~MARKDOWN
  # Change Log

  All notable changes to this project will be documented in this file.
  This project *tries* to adhere to [Semantic Versioning](http://semver.org/), even before v1.0.

  Changes are grouped as follows:
  - **Added** for new features.
  - **Changed** for changes in existing functionality.
  - **Deprecated** for once-stable features removed in upcoming releases.
  - **Removed** for deprecated features removed in this release.
  - **Fixed** for any bug fixes.
  - **Security** to invite users to upgrade in case of vulnerabilities.
MARKDOWN

desc "Update CHANGELOG.md usign info from published GitHub releases (the first unreleased section is preserved)"
task :changelog do
  changelog_path    = "#{__dir__}/../CHANGELOG.md"
  unreleased_path   = "#{__dir__}/../UNRELEASED.md"
  changelog_entries = []
  previous_tag_name = '000000'

  github_releases.call.each do |release|
    changelog_entries.unshift changelog_entry.call(
      tag_name: release[:tag_name],
      release_date: release[:created_at].to_date.iso8601, # YYYY-MM-DD
      previous_tag_name: previous_tag_name,
      body: release[:body],
    )
    previous_tag_name = release[:tag_name]
  end

  changelog_entries.unshift changelog_entry.call(
    tag_name: ENV['VERSION'] || 'HEAD',
    release_date: (ENV['VERSION'] ? Time.now.to_date.iso8601 : 'unreleased'),
    previous_tag_name: previous_tag_name,
    body: File.read(unreleased_path),
  )

  changelog_entries.unshift CHANGELOG_HEADING

  changelog_entries << nil # for the final newlines

  File.write changelog_path, changelog_entries.join("\n\n\n\n\n")
end
