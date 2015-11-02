# Contributing

This is the issue tracker for Opal. If you have a more general question about
using opal (or related libraries) then use the
[google group for opal](http://groups.google.com/forum/#!forum/opalrb), or the
[#opal](http://webchat.freenode.net/?channels=opal) irc channel on
FreeNode.

## Contributing (TL;DR)

1. Before opening a new issue, search for previous discussions including closed
ones. Add comments there if a similar issue is found.

2. Please report the version on which the issue is found.

3. Before sending pull requests make sure all tests run and pass (see below).

4. Make sure to use a similar coding style to the rest of the code base. In Ruby
and JavaScript code we use 2 spaces (no tabs).

5. Make sure to have updated all the relevant documentation, both for API and
the guides.

If unsure about having satisfied any of the above points ask in the [Gitter channel](https://gitter.im/opal/opal) or just open the issue/pull-request asking for help. There's a good chance someone will help you through the necessary steps.

## Quick Start

Fork https://github.com/opal/opal, then clone the fork to your machine:

```
$ git clone git://github.com/<Your GitHub Username>/opal.git
```

Get dependencies:

```
$ bundle install
$ npm install -g jshint
```

RubySpec related repos must be cloned as git submodules:

```
$ git submodule update --init
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

Before making changes to Opal source, you need to understand a little about how the test suite works. Every spec that Opal test suite executes is listed in `spec/rubyspecs` file. Each line in that file is a path to either a spec file or a directory full of spec files. If it's a path to a directory, all spec files in that directory will be executed when you run the test suite. Lines starting with a `!` represent files that are excluded (i.e. "execute all files in a given directory, *except* this file"), and lines starting with a `#` are ignored as comments. All paths are relative to the top-level `specs` directory. Let's follow one of these paths - `rubyspec/core/string/sub_spec` - and see where it goes.

Navigating to `spec/rubyspec/core` directory, you see that it contains multiple sub-directories, usually named after the Ruby class or module. Drilling further down into `spec/rubyspec/core/string` you see all the spec files for the various `String` behaviors under test, usually named by a method name followed by `_spec.rb`. Opening `spec/rubyspec/core/string/sub_spec.rb` you finally see the code that checks the correctness of Opal's implementation of the `String#sub` method's behavior.

When you execute `$ bundle exec rake`, the code in this file is executed, along with all the other specs in the entire test suite. It's a good idea to run the entire test suite when you feel you reached a certain milestone in the course of making your changes (exactly what that means is up to you), and definitely do `$ bundle exec rake` before commiting your changes to make sure they have not introduced regressions or other unintended side effects.

But you will want to run tests as often as possible, after every small change, and running the entire test suite will slow you down. You need to be able to execute a single spec that is concerned with the feature you are currently working on. To accomplish this, just add `PATTERN` to your spec invocation command, like this:

```
$ bundle exec rake mspec_rubyspec_node PATTERN=spec/rubyspec/core/string/sub_spec.rb
```

This will make sure that only `spec/rubyspec/core/string/sub_spec.rb` is run, and no other specs are executed. Globs can be used too:

```
$ bundle exec rake mspec_rubyspec_node PATTERN=spec/rubyspec/core/string/*_spec.rb
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

Let's recap what we covered so far. `spec/rubyspecs` is the "master list" of all the specs that get executed when you do `$ bundle exec rake`. You know where to find individual specs, inspect them, and execute them selectively or in bulk. But how do you know which specs to work on? You may be tempted to compare the contents of one of the directories in `spec/rubyspec/core` with the list of paths in `spec/rubyspecs`, add the missing paths to the "master list", run `$ bundle exec rake`, and start fixing the failures by implementing the missing features. However, chances are that as you are reading this, there are plenty of failing tests in the specs that are already listed in `spec/rubyspecs`. How can that be if `$ bundle exec rake` runs green? To understand this, you need to get acquainted with the concept of spec filters.

There are two types of spec filters in the Opal project: `spec/filters/bugs` and `spec/filters/unsupported`. Both filters have the same effect: any spec failures that are noted inside any of the files inside of these directories are ignored when running the spec suite, i.e. they are not reported as failures. Even though their effect is the same, the purpose of `bugs` and `unsupported` filters is different. As the name suggests, `unsupported` filters list _permanent_ failures, things that other Ruby implementations can do that Opal cannot and will never be able to do (by design and by virtue of being implemented on top of JavaScript running in the browser environment). `bugs` filters, on the other hand, are _temporary_ failures, problems that need to be worked on. Problems that Opal needs your help with. Think of the `bugs` directory and the files contained within it as your "TO DO" list for contributing to Opal.

Comment out any of the `fail` lines in any of the files in the `spec/filters/bugs` directory, run `$bundle exec rake`, and watch it fail. Make it pass and submit a pull request - that's all there is to it :) Happy hacking!

## Benchmarking

There are two ways to benchmark Opal's performance: one way is to write a program (or a set of programs) that takes sufficently long time to execute, then measure the execution time, and the other is to execute a specific RubySpec example (or a set of examples) multiple times, then measure the execution time. Let's call the former "traditional benchmarking", and the latter "RubySpec benchmarking".

Regardless of which of the two types of benchmarking above you happen to be doing, the reporting of benchmark results works the same way: `bundle exec rake bench:report`.

It's important to understand that benchmarking in Opal works on the principle of a single, shared benchmarking workspace, a *bench*, where the results of each benchmark run that you perform get automatically saved. When you do `bundle exec rake bench:report`, you get a combined report of all of the benchmark results that are currently sitting in your workspace. This means you can check out an older commit, run benchmarks, checkout a newer commit, run benchmarks, then run the report to see the results from the two commits side-by-side. After you're done, (or before starting a new benchmarking session), you can do `bundle exec rake bench:clear` to reset your workspace to a clean slate.

You can get a list of all the available benchmarking commands by running `bundle exec rake -T | grep bench` as shown below.
```
$ bundle exec rake -T | grep bench

rake bench:clear            # Delete all benchmark results
rake bench:opal             # Benchmark Opal
rake bench:report           # Combined report of all benchmark results
rake bench:ruby             # Benchmark Ruby
```

### Traditional Benchmarking

At the root of the opal project tree is a folder called `benchmark` that contains a file called `benchmarks`. This file lists all of the benchmarks that will be run if you do `bundle exec bench:opal` without specifying any particular benchmark file(s) as parameters to this rake task. In the example below, I pick which benchmarks to run by passing their file paths as parameters to the rake task.

Start with a clean slate:
```
$ bundle exec rake bench:clear

rm tmp/bench/*
```

Run two benchmark programs from the MRI benchmarking suite by passing their file paths as parameters:
(Note: passing params to Rake tasks is tricky - notice there is no space after the comma!)
```
$ bundle exec rake bench:opal[test/cruby/benchmark/bm_app_answer.rb,test/cruby/benchmark/bm_app_factorial.rb]

bundle exec opal benchmark/run.rb test/cruby/benchmark/bm_app_answer.rb test/cruby/benchmark/bm_app_factorial.rb | tee tmp/bench/Opal1
test/cruby/benchmark/bm_app_answer.rb    0.7710001468658447
test/cruby/benchmark/bm_app_factorial.rb 0.0820000171661377
===============================================
Executed 2 benchmarks in 0.8530001640319824 sec
```

In this case, I want to see how Opal's results stack up against MRI's results, so I will run the same set of benchmarks for Ruby:
```
$ bundle exec rake bench:ruby[test/cruby/benchmark/bm_app_answer.rb,test/cruby/benchmark/bm_app_factorial.rb]

bundle exec ruby benchmark/run.rb test/cruby/benchmark/bm_app_answer.rb test/cruby/benchmark/bm_app_factorial.rb | tee tmp/bench/Ruby1
test/cruby/benchmark/bm_app_answer.rb    0.04913724200014258
test/cruby/benchmark/bm_app_factorial.rb 1.3288652799965348
===============================================
Executed 2 benchmarks in 1.3780025219966774 sec
```

Now I'm ready to see the result of the two runs side-by-side:
```
$ bundle exec rake bench:report

Benchmark                                 Opal1  Ruby1
test/cruby/benchmark/bm_app_answer.rb     0.771  0.049
test/cruby/benchmark/bm_app_factorial.rb  0.082  1.329
```

If I were to continue running benchmarks, more columns would be added to the report. You can select which columns you want to display (and in what order) by passing their names as params to the rake task like so: `bundle exec rake bench:report[Ruby1,Opal1]`

### RubySpec Benchmarking

This type of benchmarking relies on a feature of MSpec whereby you can ask it to execute every example in a given spec multiple times. Adding `BM=<number of times>` to your regular spec suite invocation command will hook into this MSpec functionality, collect timing information, and dump the results into the benchmarking workspace, making them available for reporting. Below is an example run with a single spec and `BM` set to `100`, meaning each example in the spec would be run 100 times.

```
$ bundle exec rake mspec_rubyspec_node PATTERN=spec/rubyspec/core/array/permutation_spec.rb BM=100

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
