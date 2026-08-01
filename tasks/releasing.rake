# frozen_string_literal: true

require 'bundler'
Bundler.require
Bundler::GemHelper.install_tasks

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
  - **Performance** changes related to speed and efficiency.
MARKDOWN

desc "Update CHANGELOG.md from published GitHub releases (the unreleased section is seeded from merged pull requests)"
task :changelog do
  changelog_path    = "#{__dir__}/../CHANGELOG.md"
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

  # The changes since the last release have no GitHub release to draw from yet.
  # List the merged pull requests so whoever is preparing the release has the
  # raw material to edit down, rather than starting from a blank section.
  unreleased_body = `git log #{previous_tag_name}..HEAD --merges --pretty=format:'%s %b'`
                    .scan(%r{Merge pull request #(\d+) from \S+\s*(.*)})
                    .map { |number, subject| "- #{subject.strip} (##{number})" }
                    .join("\n")

  changelog_entries.unshift changelog_entry.call(
    tag_name: ENV['VERSION'] || 'HEAD',
    release_date: (ENV['VERSION'] ? Time.now.to_date.iso8601 : 'unreleased'),
    previous_tag_name: previous_tag_name,
    body: unreleased_body,
  )

  changelog_entries.unshift CHANGELOG_HEADING

  changelog_entries << nil # for the final newlines

  File.write changelog_path, changelog_entries.join("\n\n\n\n\n")
end

namespace :release do
  task :prepare do
    version = ENV['VERSION'] or abort "please provide a version as the first argument, e.g.: #{$0} 1.2.3"
    version = version[1..] if version.start_with? 'v'
    gem_version = Gem::Version.new(version)

    version_path = "#{__dir__}/../lib/opal/version.rb"
    puts "== update #{version_path}"
    require_relative version_path
    File.write version_path, File.read(version_path).sub(Opal::VERSION, version)

    constants_path = "#{__dir__}/../opal/corelib/constants.rb"
    puts "== update #{constants_path}"
    require_relative constants_path
    File.write constants_path, File.read(constants_path).sub(Opal::VERSION, version).sub(
      %r{(RUBY_RELEASE_DATE *= *')\d{4}-\d{2}-\d{2}(')},
      '\1' + Time.now.strftime('%F') + '\2'
    )

    if gem_version.prerelease?
      puts "== (skipping changlog update)"
    else
      puts "== update changelog"

      system "bin/rake changelog VERSION=v#{version}" or abort('changelog update failed')
    end

    puts "== committing"
    sh 'git add CHANGELOG.md opal/corelib/constants.rb lib/opal/version.rb'
    sh "git commit -m 'Release v#{version}'"
    sh 'git show | cat'
  end
end
