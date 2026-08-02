# Hacking

## Prerequisites

- **Ruby.** The gemspec requires `>= 2.3`, and CI covers 3.0 through 4.0 plus JRuby.
  CI's `DEFAULT_RUBY` is **3.4**, so that is the version to develop against if you
  want the closest match to the reference build.
- **Node.js** with `npm`. Needed for the Node-based spec runners and for the JS
  linting step. There is no pinned version; CI uses whatever its runner image ships.
- **A browser**, if you intend to run the full suite. See
  [Running the tests](#running-the-tests) below.

## Quick Start

[Fork opal/opal on GitHub](https://github.com/opal/opal/fork), then clone the fork to your machine:

```sh
$ git clone https://github.com/<YOUR-GITHUB-USERNAME>/opal.git
```

Setup the project. This installs gems, checks out the git submodules (`spec/mspec`,
`spec/ruby`, `test/cruby`) and installs the JS dependencies:

```sh
$ bin/setup
```

Then check that things work, starting with the fastest useful command:

```sh
$ bundle exec rspec spec/lib/compiler_spec.rb
```

That runs in well under a second and needs no browser and no Node.js, so it is the
best signal that your checkout is healthy. It is also the inner loop to reach for
while working on the compiler itself.

You are now ready to make your first contribution to Opal! At a high level, your workflow will be to:

1. Make changes to Opal source code
2. Run the test suite to make sure it still passes
3. Run `bin/rake lint` before pushing
4. Submit a pull request

## Running the tests

The default task runs everything:

```sh
$ bin/rake
```

It expands to `rspec`, `mspec` and `minitest`, and the latter two each fan out across
**both Chrome and Node.js**, so **the default task needs a browser installed** and takes
several minutes. On macOS the Chrome runner discovers the browser automatically from
`/Applications/Google Chrome.app` (and Chromium as a fallback), so there is no need to
put `google-chrome` on your `PATH`. Firefox is discovered from `/Applications` the same
way.

On Linux, depending on your environment, you may need to prefix browser-backed commands
with `xvfb-run` so the runners can start headless.

Narrower entry points, all of which show up in `bin/rake -T`:

```sh
$ bundle exec rspec spec/lib/compiler_spec.rb    # fastest; no browser, no Node.js
$ bin/rake rspec                                 # the Ruby-side RSpec suite
$ bin/rake mspec                                 # the whole MSpec suite, all platforms
$ bin/rake minitest                              # the whole Minitest suite, all platforms
$ bin/rake lint                                  # ESLint on the built dist + RuboCop
```

`bin/rake lint` needs `node_modules/` present, so run `bin/setup` (or `bin/yarn install`)
first.

Run `bin/rake -T` for the full list — there are runner-specific tasks for Node.js,
Chrome, Firefox, Safari, Bun, Deno, QuickJS, MiniRacer and more.


## Down The Rabbit Hole

Before making changes to Opal source, you need to understand a little about how the test suite works. Every spec that Opal test suite executes is listed in `spec/ruby_specs` file. Each line in that file is a path to either a spec file or a directory full of spec files. If it's a path to a directory, all spec files in that directory will be executed when you run the test suite. Lines starting with a `!` represent files that are excluded (i.e. "execute all files in a given directory, *except* this file"), and lines starting with a `#` are ignored as comments. All paths are relative to the top-level `specs` directory. Let's follow one of these paths - `ruby/core/string/sub_spec` - and see where it goes.

Navigating to `spec/ruby/core` directory, you see that it contains multiple sub-directories, usually named after the Ruby class or module. Drilling further down into `spec/ruby/core/string` you see all the spec files for the various `String` behaviors under test, usually named by a method name followed by `_spec.rb`. Opening `spec/ruby/core/string/sub_spec.rb` you finally see the code that checks the correctness of Opal's implementation of the `String#sub` method's behavior.

When you execute `$ bin/rake`, the code in this file is executed, along with all the other specs in the entire test suite. It's a good idea to run the entire test suite when you feel you reached a certain milestone in the course of making your changes (exactly what that means is up to you), and definitely do `$ bin/rake` before committing your changes to make sure they have not introduced regressions or other unintended side effects.

But you will want to run tests as often as possible, after every small change, and running the entire test suite will slow you down. You need to be able to execute a single spec that is concerned with the feature you are currently working on. To accomplish this, just add `PATTERN` to your spec invocation command, like this:

```sh
$ bin/rake mspec_ruby_nodejs PATTERN=spec/ruby/core/string/sub_spec.rb
```

This will make sure that only `spec/ruby/core/string/sub_spec.rb` is run, and no other specs are executed. Globs can be used too:

```sh
$ bin/rake mspec_ruby_nodejs PATTERN="spec/ruby/core/string/*_spec.rb"
```

Another way to quickly validate ideas and play with your changes is to use `opal-repl`, a tool similar to `irb`. Running `opal-repl` drops you into an interactive environment with your current version of Opal loaded, including any changes you have made.

```console
$ bundle exec opal-repl
>> 2 + 2
=> 4
>>
```

When quickly iterating on an idea, even `opal-repl` may feel a bit too heavy, because after making a change in Opal, you must `exit` from `opal-repl` and do `$ bundle exec opal-repl` again to load Opal with your latest changes. In this case, you can run `opal` with the `-e` option, which executes a piece of code you pass to it once, then returns to the shell. This means that in order to run it again after making another adjustment to Opal, all you have to do is hit the up arrow key on your keyboard and press the enter key. This is the fastest way to go from making a change in Opal to seeing its effect.

```console
$ bundle exec opal -e "3.times {puts 'hello'}"
hello
hello
hello
$
```

Let's recap what we covered so far. `spec/ruby_specs` is the "master list" of all the specs that get executed when you do `$ bin/rake`. You know where to find individual specs, inspect them, and execute them selectively or in bulk. But how do you know which specs to work on? You may be tempted to compare the contents of one of the directories in `spec/ruby/core` with the list of paths in `spec/ruby_specs`, add the missing paths to the "master list", run `$ bin/rake`, and start fixing the failures by implementing the missing features. However, chances are that as you are reading this, there are plenty of failing tests in the specs that are already listed in `spec/ruby_specs`. How can that be if `$ bin/rake` runs green? To understand this, you need to get acquainted with the concept of spec filters.

There are two types of spec filters in the Opal project: `spec/filters/bugs` and `spec/filters/unsupported`. Both filters have the same effect: any spec failures that are noted inside any of the files inside of these directories are ignored when running the spec suite, i.e. they are not reported as failures. Even though their effect is the same, the purpose of `bugs` and `unsupported` filters is different. As the name suggests, `unsupported` filters list _permanent_ failures, things that other Ruby implementations can do that Opal cannot and will never be able to do (by design and by virtue of being implemented on top of JavaScript running in the browser environment). `bugs` filters, on the other hand, are _temporary_ failures, problems that need to be worked on. Problems that Opal needs your help with. Think of the `bugs` directory and the files contained within it as your "TO DO" list for contributing to Opal.

Comment out any of the `fail` lines in any of the files in the `spec/filters/bugs` directory, run `$bin/rake`, and watch it fail. Make it pass and submit a pull request - that's all there is to it :) Happy hacking!

Core classes use each other and your changes may fix other bugs in `spec/filters/bugs`. If you think it's possible, run an inverted test suite by providing environment variable `INVERT_RUNNING_MODE=true`:

```sh
$ env INVERT_RUNNING_MODE=true RUBYSPECS=true PATTERN="spec/ruby/core/string/*_spec.rb" bin/rake mspec_ruby_nodejs
```

This command will execute tests marked as "bugs" from every file in the `spec/ruby/core/string` directory. After running it you will get a list of specs that in fact are passing. Feel free to remove them from `spec/filters/bugs`.

Note: Opal has some bugs that may cause a shared state between tests. Sometimes green specs are green only in the inverted test suite, so after removing them from `/bugs`, run a regular test suite one more time to verify that everything is fine.

Also there are some specs in `spec/ruby/language/while_spec.rb` that cause an infinite loop. Make sure to comment them before running a whole inverted test suite.

## Benchmarking

Opal benchmarking uses the standard Ruby [benchmark_driver](https://github.com/benchmark-driver/), allowing for Ruby .rb and .yaml benchmarks. Examples are available in the `benchmark` directory.

Benchmarking in Opal works on the principle of a single, shared benchmarking workspace, a *bench*, where the results of each benchmark run that you perform get automatically saved. When you do `bin/rake bench:report`, you get a combined report of all of the benchmark results that are currently sitting in your workspace. This means you can check out an older commit, run benchmarks, checkout a newer commit, run benchmarks, then run the report to see the results from the two commits side-by-side. After you're done, (or before starting a new benchmarking session), you can do `bin/rake bench:clear` to reset your workspace to a clean slate.

For the current list of benchmarking commands, run:

```sh
$ bin/rake -T | grep bench
```

That covers `bench:clear`, `bench:report`, `bench:ruby`, `bench:ruby_vs_opal`, `bench:all`,
and a `bench:opal_<runner>` task per JS runner (`opal_nodejs`, `opal_chrome`,
`opal_firefox`, `opal_safari`, `opal_bun`, `opal_deno`, `opal_quickjs`, `opal_miniracer`,
`opal_server`, `opal_applescript`). Read the list from `rake -T` rather than trusting a
copy pasted here — the runner set changes.

> **Known issue:** `benchmark/run.rb` currently raises
> `NameError: undefined local variable or method 'rubies'` on modern Rubies, because
> line 30 references `rubies` before it is assigned (it means `selected_rubies`).
> `bench:ruby` fails outright and the `bench:opal_*` tasks complete but record no
> timings. Fix that script before relying on any benchmark numbers.

On Windows make sure to enable the DevKit before running benchmarks: `ridk enable`.
On Linux, depending on your environment, it may be required to use `xvfb-run bundle exec ...` to make sure browser runners can run in headless mode.

At the root of the opal project tree is a folder called `benchmark` that contains a file called `benchmarks`. This file lists all of the benchmarks that will be run if you do `bin/rake bench:opal_nodejs` without specifying any particular benchmark file(s) as parameters to this rake task. In the example below, I pick which benchmarks to run by passing their file paths as parameters to the rake task.

Start with a clean slate:

```console
$ bin/rake bench:clear

rm tmp/bench/*
```

Run two benchmark programs from the benchmarking suite by passing their file paths as parameters:
(Note: passing params to Rake tasks is tricky - notice there is no space after the comma!)

```sh
$ bin/rake 'bench:opal_nodejs[benchmark/bm_array_flatten.rb,benchmark/bm_array_uniq_numbers.rb]'
```

Note the quotes: most shells (zsh, fish) treat `[...]` as a glob, so quote the whole task
argument. To compare against MRI, run the same set of benchmarks through the Ruby harness:

```sh
$ bin/rake 'bench:ruby[benchmark/bm_array_flatten.rb,benchmark/bm_array_uniq_numbers.rb]'
```

Then view both runs side by side:

```sh
$ bin/rake bench:report
```

If you were to continue running benchmarks, more columns would be added to the report. You can select which columns you want to display (and in what order) by passing their names as params to the rake task like so: `bin/rake bench:report[Ruby1,Opal1]`

Rubies, that are unknown to the Opal benchmarking harness, can be benchmarked by setting the `OPAL_BENCH_EXTRA_RUBIES` environment variable.
The full paths to the extra rubies must be specified, separated by ';', ready for benchmark_driver to be passed as option. Example:
`OPAL_BENCH_EXTRA_RUBIES="/usr/local/bin/ruby.wasm;/usr/local/bin/ruby.head"`

### The Ruby Spec Suite Benchmarking

This type of benchmarking relies on a feature of MSpec whereby you can ask it to execute every example in a given spec multiple times. Adding `BM=<number of times>` to your regular spec suite invocation command will hook into this MSpec functionality, collect timing information, and dump the results into the benchmarking workspace, making them available for reporting. Below is an example run with a single spec and `BM` set to `100`, meaning each example in the spec would be run 100 times.

```console
$ bin/rake mspec_ruby_nodejs PATTERN=spec/ruby/core/array/permutation_spec.rb BM=100

...

Benchmark results have been written to tmp/bench/Spec1
To view the results, run bin/rake bench:report
```

Now let's see the report:
(Spec names can be very long, scroll to the right to see the numbers)

```console
$ bin/rake bench:report
Benchmark                                                                                                                     Spec1
Array#permutation_returns_an_Enumerator_of_all_permutations_when_called_without_a_block_or_arguments                          0.117
Array#permutation_returns_an_Enumerator_of_permutations_of_given_length_when_called_with_an_argument_but_no_block             0.064
Array#permutation_yields_all_permutations_to_the_block_then_returns_self_when_called_with_block_but_no_arguments              0.076
Array#permutation_yields_all_permutations_of_given_length_to_the_block_then_returns_self_when_called_with_block_and_argument  0.072
Array#permutation_returns_the_empty_permutation_([[]])_when_the_given_length_is_0                                             0.029
Array#permutation_returns_the_empty_permutation([])_when_called_on_an_empty_Array                                             0.029
Array#permutation_returns_no_permutations_when_the_given_length_has_no_permutations                                           0.029
Array#permutation_handles_duplicate_elements_correctly                                                                        0.081
Array#permutation_handles_nested_Arrays_correctly                                                                             0.085
Array#permutation_truncates_Float_arguments                                                                                   0.063
Array#permutation_returns_an_Enumerator_which_works_as_expected_even_when_the_array_was_modified                              0.056
Array#permutation_generates_from_a_defensive_copy,_ignoring_mutations                                                         0.038
```

### AsciiDoctor Benchmark and git branch performance comparison

It is testing the performance for the real life application AsciiDoctor, compiling it, running it and asset size.
It prints a nice summary to compare the current branch with the master branch.
On Windows make sure to have the Ruby DevKit enabled with `ridk enable`.

Run the task on any system with: `bin/rake performance:compare`

Prerequisites, neither of which the task checks for you:

- **[bun](https://bun.sh) must be installed.** CI installs it explicitly for this job.
- **A full, non-shallow clone with tags.** The task runs `git describe --tags` and
  `git checkout --recurse-submodules <ref>` to build both the current branch and master,
  so a `--depth 1` clone will fail. CI uses `fetch-depth: 0` for this job. If you cloned
  shallowly, run `git fetch --unshallow --tags` first.

Note: `performance:compare` has no `desc`, so it does not appear in `bin/rake -T`; use
`bin/rake -AT | grep performance` to see it.

Example output (numbers and refs will differ):

```text
=== Summary ===
Summary of performance changes between (previous) master and (current) <your-ref>:

Comparison of V8 function optimization status:
tmp/performance/optstatus_previous and tmp/performance/optstatus_current are identical.

Comparison of the Asciidoctor (a real-life Opal application) compile and run:
                  Compile time: 9.367 (±2.21%) -> 9.579 (±17.53%) (change: +2.26%)
                      Run time: 2.049 (±9.25%) -> 2.147 (±19.70%) (change: +4.80%)
                   Bundle size: 4740.27 kB -> 4740.27 kB (change: +0.00%)
          Minified bundle size: 995.10 kB -> 995.10 kB (change: +0.00%)
            Mangled & minified: 706.32 kB -> 706.32 kB (change: +0.00%)
```

## Parser

Opal relies on the `parser` gem, see debug/development documentation there to know more about its internals: https://whitequark.github.io/parser/.

## Profiling

For the node runner profiling can be enabled by setting the `NODE_FLAME` environment variable. In addition 0x must be installed globally: `npm i 0x -g`. When using the node runner afterwards, it will profile the program execution and at programm exit generate a nice flamegraph that can be examined in a browser. To disable profiling again, the `NODE_FLAME` environment variable must be unset.
