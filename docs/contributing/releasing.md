# Releasing

_This guide is a work-in-progress._

---

## Before the release

All of the following is now covered by `bin/rake release:prepare VERSION=v1.2.3`

1. Update the version
   - Update `lib/opal/version.rb`
   - Update `opal/corelib/constants.rb` with the same version number along with release dates
1. Update the changelog
   - [skip for pre-releases] Run `bin/rake changelog VERSION=v1.2.3` specifying the version number you're about to release

     Released versions are regenerated from their GitHub releases. The
     "Unreleased" section at the top is seeded from the pull requests merged
     since the last tag, which is raw material rather than a finished
     changelog — edit it down before committing.
1. Commit the updated changelog along with the version bump using this commit message: "Release v1.2.3"

---

## Release!

- Push the commit to `master` or the current stable branch
- Run `bin/rake release` to release the new version to Rubygems
- Go to GitHub releases and create a new release from the latest tag pasting the contents from CHANGELOG.md (or UNRELEASED.md for pre-releases)

---

## After the release

### Opal docs

- Open `opal-docs` and run `bin/build v1.2.3`
- Then run `bin/deploy`

### [skip for pre-releases] Opal site

- Open `opal.github.io`
- checkout the `source` branch
- update the opal version in the `Gemfile` with `bundle update opal`
- run `bin/build`
- `git push` the latest changes

### Opal CDN

- Run `bin/release v1.2.3`

### [skip for minor-releases] Prepare for the next release

- Create a new pull request that:
  - Updates a version to `v1.x.0.dev` in both `lib/opal/version.rb` and `opal/corelib/constants.rb`
- Remember to merge that PR before merging anything else next once we decide to not release any more point releases from `master`.
