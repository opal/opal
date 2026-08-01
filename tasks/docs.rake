# Documentation anti-rot tasks.
#
# NOTE: docs/ is published as HTML, so guides link to each other using the
# rendered `name.html` / `../dir/name.html` form even though the sources are
# `.md`. Any off-the-shelf link checker either reports those as 404 (the .html
# files do not exist in the repo) or skips them entirely. `docs:links` maps
# .html back to .md and resolves it relative to the containing file, which is
# what actually catches a broken cross-reference before it ships.

namespace :docs do
  # Files we consider "docs" for link purposes.
  DOC_GLOBS = %w[docs/**/*.md *.md].freeze

  # Matches the target of a markdown link that points at a rendered page,
  # capturing the path and any trailing anchor separately.
  DOC_LINK = /\]\(([^)\s]+\.html)(#[^)]*)?\)/.freeze

  desc 'Verify every relative link between documentation pages resolves to a real file'
  task :links do
    files = DOC_GLOBS.flat_map { |glob| Dir[glob] }.uniq.sort
    broken = []

    files.each do |file|
      File.read(file).scan(DOC_LINK) do |target, _anchor|
        # External and site-absolute links are lychee's job, not ours.
        next if target.match?(%r{\A(?:[a-z][a-z0-9+.-]*:)?//}i)
        next if target.start_with?('/', '#')

        source = File.join(File.dirname(file), target.sub(/\.html\z/, '.md'))
        broken << [file, target] unless File.exist?(source)
      end
    end

    if broken.empty?
      puts "ALL INTERNAL LINKS OK (#{files.size} files checked)"
    else
      broken.each { |file, target| warn "#{file}: broken link -> #{target}" }
      abort "\n#{broken.size} broken internal link(s) found in #{files.size} files checked"
    end
  end

  desc 'Lint markdown documentation with markdownlint-cli2'
  task :markdownlint do
    sh 'bin/yarn', 'run', 'markdownlint-cli2'
  end

  desc 'Run all documentation checks that are safe to block a pull request'
  task :check => %w[docs:links docs:markdownlint]
end
