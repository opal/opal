# NOTE: run bin/format-filters after changing this file
opal_filter "String" do
  fails "String#each_grapheme_cluster is unicode aware" # Exception: 'Intl' is not defined
  fails "String#each_grapheme_cluster passes each char in self to the given block" # Exception: 'Intl' is not defined
  fails "String#each_grapheme_cluster passes each grapheme cluster in self to the given block" # Exception: 'Intl' is not defined
  fails "String#each_grapheme_cluster returns characters in the same encoding as self" # Exception: 'Intl' is not defined
  fails "String#each_grapheme_cluster returns self" # Exception: 'Intl' is not defined
  fails "String#each_grapheme_cluster when no block is given returns an enumerator" # Exception: 'Intl' is not defined
  fails "String#each_grapheme_cluster works with multibyte characters" # Exception: 'Intl' is not defined
  fails "String#each_grapheme_cluster yields String instances for subclasses" # Exception: 'Intl' is not defined
  fails "String#grapheme_clusters is unicode aware" # Exception: 'Intl' is not defined
  fails "String#grapheme_clusters passes each char in self to the given block" # Exception: 'Intl' is not defined
  fails "String#grapheme_clusters passes each grapheme cluster in self to the given block" # Exception: 'Intl' is not defined
  fails "String#grapheme_clusters returns an array when no block given" # Exception: 'Intl' is not defined
  fails "String#grapheme_clusters returns characters in the same encoding as self" # Exception: 'Intl' is not defined
  fails "String#grapheme_clusters returns self" # Exception: 'Intl' is not defined
  fails "String#grapheme_clusters works with multibyte characters" # Exception: 'Intl' is not defined
end
