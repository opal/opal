opal_filter "Strict" do
  fails "Array#inspect does not call #to_s on a String returned from #inspect" # NameError: method 'to_s' not defined in
  fails "Array#to_s does not call #to_s on a String returned from #inspect" # NameError: method 'to_s' not defined in
  fails "Kernel#Float converts Strings to floats without calling #to_f" # NameError: method 'to_f' not defined in
  fails "Kernel#String returns the same object if it is already a String" # NameError: method 'to_s' not defined in
  fails "Kernel#public_methods returns public methods for immediates" # Exception: Object.defineProperty called on non-object
  fails "Kernel.Float converts Strings to floats without calling #to_f" # NameError: method 'to_f' not defined in
  fails "Kernel.String returns the same object if it is already a String" # NameError: method 'to_s' not defined in
  fails "Time.at passed [Time, Numeric, format] not supported format does not try to convert format to Symbol with #to_sym" # NameError: method 'to_sym' not defined in
end