DependencyBuilder will gather a list of dependencies to be built in the following order:

1. If rake task is given array of dependencies, they will be used
2. If a `Gemfile` exists, the dependencies will be gathered from the :`opal` group
3. If a `.gemspec` exists, all runtime dependencies listed in the gemspec will be used

In all three cases, all the dependencies of these listed dependencies will also be built. It is important to only include opal specific gems as runtime dependencies. In Gemfiles, simply list all external dependencies (including opal, rake, therubyracer etc) outside the `:opal` group.