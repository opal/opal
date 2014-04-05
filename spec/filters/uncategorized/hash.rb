opal_filter "Hash" do
  fails "Hash.[] removes the default_proc"
  fails "Hash#default_proc= raises a RuntimeError if self is frozen"
  fails "Hash#delete_if raises a RuntimeError if called on a frozen instance"
  fails "Hash#flatten raises a TypeError if given a non-Integer argument"
  fails "Hash#inspect returns a tainted string if self is tainted and not empty"
  fails "Hash#inspect returns an untrusted string if self is untrusted and not empty"
  fails "Hash#keep_if raises a RuntimeError if called on a frozen instance"
  fails "Hash#to_a returns a tainted array if self is tainted"
  fails "Hash#to_a returns an untrusted array if self is untrusted"
  fails "Hash#to_h returns self for Hash instances"
  fails "Hash#to_s returns a tainted string if self is tainted and not empty"
  fails "Hash#to_s returns an untrusted string if self is untrusted and not empty"
end
