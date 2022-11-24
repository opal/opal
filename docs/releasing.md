# Releasing

_This guide is a work-in-progress._

## Updating the version

- Update `lib/opal/version.rb`
- Update `opal/corelib/constants.rb` with the same version number along with release dates

## Updating the changelog

- Ensure all the unreleased changes are documented in UNRELEASED.md
- [skip for pre-releases] Run `bin/rake changelog VERSION=v1.2.3` specifying the version number you're about to release
- [skip for pre-releases] Empty UNRELEASED.md

## The commit

- Commit the updated changelog along with the version bump using this commit message:
  "Release v1.2.3"
- Push the commit and run `bin/rake release` to release the new version to Rubygems
- Go to GitHub releases and create a new release from the latest tag pasting the contents from CHANGELOG.md (or UNRELEASED.md for pre-releases)

## Opal docs

- Open `opal-docs` and run `bin/build v1.2.3`
- Then run `bin/deploy`

## [skip for pre-releases] Opal site

- Open `opal.github.io` and update the opal version in the `Gemfile`
- run `bin/build`
- `git push` the latest changes

## Opal CDN

- Run `bin/release v1.2.3`

## [skip for minor-releases] Prepare for the next release

- Create a new pull request that:
  - Updates a version to `v1.x.0.dev` in both `lib/opal/version.rb` and `opal/corelib/constants.rb`
- Remember to merge that PR before merging anything else next once we decide to not release any more point releases from `master`.

