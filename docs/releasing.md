# Releasing

_This guide is a work-in-progress._

## Updating the version

- Update `lib/opal/version.rb`
- Update `opal/corelib/constants.rb` with the same version number along with release dates

## Updating the changelog

- Ensure all the unreleased changes are documented in UNRELEASED.md
- Run `bin/rake changelog VERSION=v1.2.3` specifying the version number you're about to release

## The commit

- Commit the updated changelog along with the version bump using this commmit message:
  "Release v1.2.3"
