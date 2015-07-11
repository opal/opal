opal_filter "Array" do
  fails "Array#* with a string with a tainted separator does not taint the result if the array has only one element"
  fails "Array#* with a string with a tainted separator does not taint the result if the array is empty"
  fails "Array#* with a string with a tainted separator taints the result if the array has two or more elements"
  fails "Array#* with a string with an untrusted separator does not untrust the result if the array has only one element"
  fails "Array#* with a string with an untrusted separator does not untrust the result if the array is empty"
  fails "Array#* with a string with an untrusted separator untrusts the result if the array has two or more elements"
  fails "Array#* with an integer copies the taint status of the original array even if the array is empty"
  fails "Array#* with an integer copies the taint status of the original array even if the passed count is 0"
  fails "Array#* with an integer copies the taint status of the original array if the passed count is not 0"
  fails "Array#* with an integer copies the untrusted status of the original array even if the array is empty"
  fails "Array#* with an integer copies the untrusted status of the original array even if the passed count is 0"
  fails "Array#* with an integer copies the untrusted status of the original array if the passed count is not 0"
  fails "Array#+ does not get infected even if an original array is tainted"
  fails "Array#+ does not infected even if an original array is untrusted"
  fails "Array#[] raises a RangeError when the length is out of range of Fixnum"
  fails "Array#[] raises a RangeError when the start index is out of range of Fixnum"
  fails "Array#clear keeps tainted status"
  fails "Array#clear keeps untrusted status"
  fails "Array#clone copies taint status from the original"
  fails "Array#clone copies untrusted status from the original"
  fails "Array#collect does not copy tainted status"
  fails "Array#collect does not copy untrusted status"
  fails "Array#collect! keeps tainted status"
  fails "Array#collect! keeps untrusted status"
  fails "Array#compact does not keep tainted status even if all elements are removed"
  fails "Array#compact does not keep untrusted status even if all elements are removed"
  fails "Array#compact! keeps tainted status even if all elements are removed"
  fails "Array#compact! keeps untrusted status even if all elements are removed"
  fails "Array#concat is not infected by the other"
  fails "Array#concat is not infected untrustedness by the other"
  fails "Array#concat keeps tainted status"
  fails "Array#concat keeps the tainted status of elements"
  fails "Array#concat keeps the untrusted status of elements"
  fails "Array#concat keeps untrusted status"
  fails "Array#delete keeps tainted status"
  fails "Array#delete keeps untrusted status"
  fails "Array#delete_at keeps tainted status"
  fails "Array#delete_at keeps untrusted status"
  fails "Array#delete_if keeps tainted status"
  fails "Array#delete_if keeps untrusted status"
  fails "Array#dup copies taint status from the original"
  fails "Array#dup copies untrusted status from the original"
  fails "Array#eql? returns false if any corresponding elements are not #eql?"
  fails "Array#fill does not replicate the filler"
  fails "Array#fill with (filler, index, length) raises an ArgumentError or RangeError for too-large sizes"
  fails "Array#flatten returns a tainted array if self is tainted"
  fails "Array#flatten returns an untrusted array if self is untrusted"
  fails "Array#initialize is private"
  fails "Array#initialize_copy is private"
  fails "Array#inspect does not taint the result if the Array is tainted but empty"
  fails "Array#inspect does not untrust the result if the Array is untrusted but empty"
  fails "Array#inspect raises if inspected result is not default external encoding"
  fails "Array#inspect represents a recursive element with '[...]'"
  fails "Array#inspect returns a US-ASCII string for an empty Array"
  fails "Array#inspect taints the result if an element is tainted"
  fails "Array#inspect taints the result if the Array is non-empty and tainted"
  fails "Array#inspect untrusts the result if an element is untrusted"
  fails "Array#inspect untrusts the result if the Array is untrusted"
  fails "Array#inspect use US-ASCII encoding if the default external encoding is not ascii compatible"
  fails "Array#inspect use the default external encoding if it is ascii compatible"
  fails "Array#inspect with encoding raises if inspected result is not default external encoding"
  fails "Array#inspect with encoding returns a US-ASCII string for an empty Array"
  fails "Array#inspect with encoding use US-ASCII encoding if the default external encoding is not ascii compatible"
  fails "Array#inspect with encoding use the default external encoding if it is ascii compatible"
  fails "Array#join does not taint the result if the Array is tainted but empty"
  fails "Array#join does not untrust the result if the Array is untrusted but empty"
  fails "Array#join fails for arrays with incompatibly-encoded strings"
  fails "Array#join returns a US-ASCII string for an empty Array"
  fails "Array#join taints the result if the Array is tainted and non-empty"
  fails "Array#join taints the result if the result of coercing an element is tainted"
  fails "Array#join untrusts the result if the Array is untrusted and non-empty"
  fails "Array#join untrusts the result if the result of coercing an element is untrusted"
  fails "Array#join uses the first encoding when other strings are compatible"
  fails "Array#join uses the widest common encoding when other strings are incompatible"
  fails "Array#join with a tainted separator does not taint the result if the array has only one element"
  fails "Array#join with a tainted separator does not taint the result if the array is empty"
  fails "Array#join with a tainted separator taints the result if the array has two or more elements"
  fails "Array#join with an untrusted separator does not untrust the result if the array has only one element"
  fails "Array#join with an untrusted separator does not untrust the result if the array is empty"
  fails "Array#join with an untrusted separator untrusts the result if the array has two or more elements"
  fails "Array#map does not copy tainted status"
  fails "Array#map does not copy untrusted status"
  fails "Array#map! keeps tainted status"
  fails "Array#map! keeps untrusted status"
  fails "Array#pop keeps taint status"
  fails "Array#pop keeps untrusted status"
  fails "Array#pop passed a number n as an argument keeps taint status"
  fails "Array#pop passed a number n as an argument keeps untrusted status"
  fails "Array#pop passed a number n as an argument returns a trusted array even if the array is untrusted"
  fails "Array#pop passed a number n as an argument returns an untainted array even if the array is tainted"
  fails "Array#replace raises a RuntimeError on a frozen array"
  fails "Array#reverse! raises a RuntimeError on a frozen array"
  fails "Array#select! on frozen objects with falsy block keeps elements after any exception"
  fails "Array#select! on frozen objects with falsy block raises a RuntimeError"
  fails "Array#select! on frozen objects with truthy block keeps elements after any exception"
  fails "Array#select! on frozen objects with truthy block raises a RuntimeError"
  fails "Array#shift passed a number n as an argument keeps taint status"
  fails "Array#shift passed a number n as an argument returns an untainted array even if the array is tainted"
  fails "Array#shift raises a RuntimeError on a frozen array"
  fails "Array#shift raises a RuntimeError on an empty frozen array"
  fails "Array#shuffle uses default random generator"
  fails "Array#shuffle uses given random generator"
  fails "Array#shuffle! raises a RuntimeError on a frozen array"
  fails "Array#slice raises a RangeError when the length is out of range of Fixnum"
  fails "Array#slice raises a RangeError when the start index is out of range of Fixnum"
  fails "Array#slice! raises a RuntimeError on a frozen array"
  fails "Array#sort! raises a RuntimeError on a frozen array"
  fails "Array#to_s does not taint the result if the Array is tainted but empty"
  fails "Array#to_s does not untrust the result if the Array is untrusted but empty"
  fails "Array#to_s raises if inspected result is not default external encoding"
  fails "Array#to_s represents a recursive element with '[...]'"
  fails "Array#to_s returns a US-ASCII string for an empty Array"
  fails "Array#to_s taints the result if an element is tainted"
  fails "Array#to_s taints the result if the Array is non-empty and tainted"
  fails "Array#to_s untrusts the result if an element is untrusted"
  fails "Array#to_s untrusts the result if the Array is untrusted"
  fails "Array#to_s use US-ASCII encoding if the default external encoding is not ascii compatible"
  fails "Array#to_s use the default external encoding if it is ascii compatible"
  fails "Array#to_s with encoding raises if inspected result is not default external encoding"
  fails "Array#to_s with encoding returns a US-ASCII string for an empty Array"
  fails "Array#to_s with encoding use US-ASCII encoding if the default external encoding is not ascii compatible"
  fails "Array#to_s with encoding use the default external encoding if it is ascii compatible"
  fails "Array#uniq! doesn't yield to the block on a frozen array"
  fails "Array#uniq! raises a RuntimeError on a frozen array when the array is modified"
  fails "Array#uniq! raises a RuntimeError on a frozen array when the array would not be modified"
  fails "Array#unshift raises a RuntimeError on a frozen array when the array is modified"
  fails "Array#unshift raises a RuntimeError on a frozen array when the array would not be modified"
end
