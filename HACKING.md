# Hacking

## Quick Start

[Fork opal/opal on GitHub](https://github.com/opal/opal/fork), then clone the fork to your machine:

```
$ git clone git://github.com/<YOUR-GITHUB-USERNAME>/opal.git
```

Setup the project:

```
$ bin/setup
```

Run the test suite:

```
$ bundle exec rake
```

You are now ready to make your first contribution to Opal! At a high level, your workflow will be to:

1. Make changes to Opal source code
2. Run the test suite to make sure it still passes
3. Submit a pull request


## Down The Rabbit Hole

Before making changes to Opal source, you need to understand a little about how the test suite works. Every spec that Opal test suite executes is listed in `spec/ruby_specs` file. Each line in that file is a path to either a spec file or a directory full of spec files. If it's a path to a directory, all spec files in that directory will be executed when you run the test suite. Lines starting with a `!` represent files that are excluded (i.e. "execute all files in a given directory, *except* this file"), and lines starting with a `#` are ignored as comments. All paths are relative to the top-level `specs` directory. Let's follow one of these paths - `ruby/core/string/sub_spec` - and see where it goes.

Navigating to `spec/ruby/core` directory, you see that it contains multiple sub-directories, usually named after the Ruby class or module. Drilling further down into `spec/ruby/core/string` you see all the spec files for the various `String` behaviors under test, usually named by a method name followed by `_spec.rb`. Opening `spec/ruby/core/string/sub_spec.rb` you finally see the code that checks the correctness of Opal's implementation of the `String#sub` method's behavior.

When you execute `$ bundle exec rake`, the code in this file is executed, along with all the other specs in the entire test suite. It's a good idea to run the entire test suite when you feel you reached a certain milestone in the course of making your changes (exactly what that means is up to you), and definitely do `$ bundle exec rake` before committing your changes to make sure they have not introduced regressions or other unintended side effects.

But you will want to run tests as often as possible, after every small change, and running the entire test suite will slow you down. You need to be able to execute a single spec that is concerned with the feature you are currently working on. To accomplish this, just add `PATTERN` to your spec invocation command, like this:

```
$ bundle exec rake mspec_ruby_nodejs PATTERN=spec/ruby/core/string/sub_spec.rb
```

This will make sure that only `spec/ruby/core/string/sub_spec.rb` is run, and no other specs are executed. Globs can be used too:

```
$ bundle exec rake mspec_ruby_nodejs PATTERN="spec/ruby/core/string/*_spec.rb"
```

Another way to quickly validate ideas and play with your changes is to use `opal-repl`, a tool similar to `irb`. Running `opal-repl` drops you into an interactive environment with your current version of Opal loaded, including any changes you have made.

```
$ bundle exec opal-repl
>> 2 + 2
=> 4
>>
```

When quickly iterating on an idea, even `opal-repl` may feel a bit too heavy, because after making a change in Opal, you must `exit` from `opal-repl` and do `$ bundle exec opal-repl` again to load Opal with your latest changes. In this case, you can run `opal` with the `-e` option, which executes a piece of code you pass to it once, then returns to the shell. This means that in order to run it again after making another adjustment to Opal, all you have to do is hit the up arrow key on your keyboard and press the enter key. This is the fastest way to go from making a change in Opal to seeing its effect.

```
$ bundle exec opal -e "3.times {puts 'hello'}"
hello
hello
hello
$
```

Let's recap what we covered so far. `spec/ruby_specs` is the "master list" of all the specs that get executed when you do `$ bundle exec rake`. You know where to find individual specs, inspect them, and execute them selectively or in bulk. But how do you know which specs to work on? You may be tempted to compare the contents of one of the directories in `spec/ruby/core` with the list of paths in `spec/ruby_specs`, add the missing paths to the "master list", run `$ bundle exec rake`, and start fixing the failures by implementing the missing features. However, chances are that as you are reading this, there are plenty of failing tests in the specs that are already listed in `spec/ruby_specs`. How can that be if `$ bundle exec rake` runs green? To understand this, you need to get acquainted with the concept of spec filters.

There are two types of spec filters in the Opal project: `spec/filters/bugs` and `spec/filters/unsupported`. Both filters have the same effect: any spec failures that are noted inside any of the files inside of these directories are ignored when running the spec suite, i.e. they are not reported as failures. Even though their effect is the same, the purpose of `bugs` and `unsupported` filters is different. As the name suggests, `unsupported` filters list _permanent_ failures, things that other Ruby implementations can do that Opal cannot and will never be able to do (by design and by virtue of being implemented on top of JavaScript running in the browser environment). `bugs` filters, on the other hand, are _temporary_ failures, problems that need to be worked on. Problems that Opal needs your help with. Think of the `bugs` directory and the files contained within it as your "TO DO" list for contributing to Opal.

Comment out any of the `fail` lines in any of the files in the `spec/filters/bugs` directory, run `$bundle exec rake`, and watch it fail. Make it pass and submit a pull request - that's all there is to it :) Happy hacking!

Core classes use each other and your changes may fix other bugs in `spec/filters/bugs`. If you think it's possible, run an inverted test suite by providing environment variable `INVERT_RUNNING_MODE=true`:

```
$ env INVERT_RUNNING_MODE=true RUBYSPECS=true PATTERN="spec/ruby/core/string/*_spec.rb" rake mspec_ruby_nodejs
```

This command will execute tests marked as "bugs" from every file in the `spec/ruby/core/string` directory. After running it you will get a list of specs that in fact are passing. Feel free to remove them from `spec/filters/bugs`.

Note: Opal has some bugs that may cause a shared state between tests. Sometimes green specs are green only in the inverted test suite, so after removing them from `/bugs`, run a regular test suite one more time to verify that everything is fine.

Also there are some specs in `spec/ruby/language/while_spec.rb` that cause an infinite loop. Make sure to comment them before running a whole inverted test suite.

## Benchmarking

Opal benchmarking uses the standard Ruby [benchmark_driver](https://github.com/benchmark-driver/), allowing for Ruby .rb and .yaml benchmarks. Examples are available in the `benchmark` directory.

Benchmarking in Opal works on the principle of a single, shared benchmarking workspace, a *bench*, where the results of each benchmark run that you perform get automatically saved. When you do `bundle exec rake bench:report`, you get a combined report of all of the benchmark results that are currently sitting in your workspace. This means you can check out an older commit, run benchmarks, checkout a newer commit, run benchmarks, then run the report to see the results from the two commits side-by-side. After you're done, (or before starting a new benchmarking session), you can do `bundle exec rake bench:clear` to reset your workspace to a clean slate.

You can get a list of all the available benchmarking commands by running `bundle exec rake -T | grep bench` as shown below.

On Windows make sure to enable the DevKit before running benchmarks: `ridk enable`.
On Linux, depending on your environment, it may be required to use `xvfb-run bundle exec ...` to make sure browser runners can run in headless mode.

```
$ bundle exec rake -T | grep bench

rake bench:clear            # Delete all benchmark results
rake bench:opal_chrome      # Benchmark Opal with Chrome runner
rake bench:opal_firefox     # Benchmark Opal with Firefox runner
rake bench:opal_node        # Benchmark Opal with Node runner
rake bench:ruby             # Benchmark Ruby
rake bench:ruby_vs_opal     # Benchmark Ruby vs Opal Node
rake bench:all              # Benchmark Ruby vs Opal Node vs Opal Chrome vs Opal Firefox
rake bench:report           # Combined report of all benchmark results
```

At the root of the opal project tree is a folder called `benchmark` that contains a file called `benchmarks`. This file lists all of the benchmarks that will be run if you do `bundle exec bench:opal_node` without specifying any particular benchmark file(s) as parameters to this rake task. In the example below, I pick which benchmarks to run by passing their file paths as parameters to the rake task.

Start with a clean slate:

```
$ bundle exec rake bench:clear

rm tmp/bench/*
```

Run two benchmark programs from the benchmarking suite by passing their file paths as parameters:
(Note: passing params to Rake tasks is tricky - notice there is no space after the comma!)

```
$ bundle exec rake bench:opal_node[benchmark/bm_array_flatten.rb,benchmark/bm_array_add.rb]
bundle exec ruby benchmark/run.rb -node benchmark/bm_array_flatten.rb benchmark/bm_array_add.rb | tee tmp/bench/1_opal-node-1-5-1.txt

Benchmarking benchmark/bm_array_add.rb started at 2022-11-06 10:20:57 +0100:
Calculating -------------------------------------
        bm_array_add                  1.941k i/s -       1.000 times in 0.000515s (515.20μs/i)

Benchmarking benchmark/bm_array_flatten.rb started at 2022-11-06 10:21:05 +0100:
Calculating -------------------------------------
    bm_array_flatten                   1.037 i/s -       1.000 times in 0.964620s (964.62ms/i)


        bm_array_add                  1.941k i/s -       1.000 times in 0.000515s (515.20μs/i)
    bm_array_flatten                   1.037 i/s -       1.000 times in 0.964620s (964.62ms/i)
```

In this case, I want to see how Opal's results stack up against MRI's results, so I will run the same set of benchmarks for Ruby:

```
$ bundle exec rake bench:ruby[benchmark/bm_array_flatten.rb,benchmark/bm_array_add.rb]
bundle exec ruby benchmark/run.rb -ruby benchmark/bm_array_flatten.rb benchmark/bm_array_add.rb | tee tmp/bench/2_ruby-3-2-0.txt

Benchmarking benchmark/bm_array_add.rb started at 2022-11-06 10:22:23 +0100:
Calculating -------------------------------------
        bm_array_add                    14.306k i/s -       1.000 times in 0.000070s (69.90μs/i)

Benchmarking benchmark/bm_array_flatten.rb started at 2022-11-06 10:22:27 +0100:
Calculating -------------------------------------
    bm_array_flatten                      7.347 i/s -       1.000 times in 0.136105s (136.10ms/i)


        bm_array_add                    14.306k i/s -       1.000 times in 0.000070s (69.90μs/i)
    bm_array_flatten                      7.347 i/s -       1.000 times in 0.136105s (136.10ms/i)
```

Now I'm ready to see the result of the two runs side-by-side:

```
$ bundle exec rake bench:report
Base: 1_opal-node-1-5-1
Benchmark                  1_opal-node-1-5-1 |                2_ruby-3-2-0 |
bm_array_flatten                   1.037 i/s |         +608.49%  7.347 i/s |
bm_array_add                    1941.000 i/s |     +637.04%  14306.000 i/s |
```

If I were to continue running benchmarks, more columns would be added to the report. You can select which columns you want to display (and in what order) by passing their names as params to the rake task like so: `bundle exec rake bench:report[Ruby1,Opal1]`

Rubies, that are unknown to the Opal benchmarking harness, can be benchmarked by setting the `OPAL_BENCH_EXTRA_RUBIES` environment variable.
The full paths to the extra rubies must be specified, separated by ';', ready for benchmark_driver to be passed as option. Example:
`OPAL_BENCH_EXTRA_RUBIES="/usr/local/bin/ruby.wasm;/usr/local/bin/ruby.head"`

### The Ruby Spec Suite Benchmarking

This type of benchmarking relies on a feature of MSpec whereby you can ask it to execute every example in a given spec multiple times. Adding `BM=<number of times>` to your regular spec suite invocation command will hook into this MSpec functionality, collect timing information, and dump the results into the benchmarking workspace, making them available for reporting. Below is an example run with a single spec and `BM` set to `100`, meaning each example in the spec would be run 100 times.

```
$ bundle exec rake mspec_ruby_nodejs PATTERN=spec/ruby/core/array/permutation_spec.rb BM=100

...

Benchmark results have been written to tmp/bench/Spec1
To view the results, run bundle exec rake bench:report
```

Now let's see the report:
(Spec names can be very long, scroll to the right to see the numbers)

```
$ bundle exec rake bench:report
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

Run the task on any system with: `bundle exec rake performance:compare`

Example output:
```
=== Summary ===
Summary of performance changes between (previous) master and (current) v1.5.1-48-gc470e969:

Comparison of V8 function optimization status:
Dateien tmp/performance/optstatus_previous und tmp/performance/optstatus_current sind identisch.

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

For the node runner profiling can be enbled by setting the `NODE_FLAME` environment variable. In addition 0x must be installed globally: `npm i 0x -g`. When using the node runner afterwards, it will profile the program execution and at programm exit generate a nice flamegraph that can be examined in a browser. To disable profiling again, the `NODE_FLAME` environment variable must be unset.
