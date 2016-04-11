opal_filter "compiler (opal)" do
  fails 'Opal::Compiler should compile undef calls'
  fails 'Opal::Compiler method names when function name is reserved generates a valid named function for method'
  fails 'Opal::Compiler pre-processing require-ish methods #require_relative parses and resolve #require_relative argument'
  fails 'Opal::Compiler pre-processing require-ish methods #require_tree parses and resolve #require argument'
end
