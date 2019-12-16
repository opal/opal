# Releasing

1. Update the changelog: use the unreleased link to ensure every relevant change has an entry in `RELEASE-NOTES.md`.
2. Update the version and release date inside `lib/opal/version.rb` and `opal/corelib/constants.rb`.
3. Push and run `bin/rake release` to create the tag and publish the gem.
4. Update docs with `bin/build` inside opal-docs.
