opal_unsupported_filter "Enumerator" do
  fails "Enumerator#next cannot be called again until the enumerator is rewound"
  fails "Enumerator#next raises a StopIteration exception at the end of the stream"
  fails "Enumerator#next returns the next element of the enumeration"
  fails "Enumerator#rewind calls the enclosed object's rewind method if one exists"
  fails "Enumerator#rewind clears a pending #feed value"
  fails "Enumerator#rewind does nothing if the object doesn't have a #rewind method"
  fails "Enumerator#rewind has no effect if called multiple, consecutive times"
  fails "Enumerator#rewind has no effect on a new enumerator"
  fails "Enumerator#rewind resets the enumerator to its initial state"
  fails "Enumerator#rewind returns self"
  fails "Enumerator#rewind works with peek to reset the position"
end
