# NOTE: run bin/format-filters after changing this file
opal_filter "IO" do
  fails "IO#read with internal encoding not specified does not transcode the String" # Exception: Unsupported encoding label "euc-jp"
  fails "IO#read with internal encoding not specified sets the String encoding to the external encoding" # Exception: Unsupported encoding label "euc-jp"
  fails "IO#read with internal encoding specified by encoding: option returns a transcoded String" # Exception: Unsupported encoding label "euc-jp"
  fails "IO#read with internal encoding specified by encoding: option sets the String encoding to the internal encoding" # Exception: Unsupported encoding label "euc-jp"
  fails "IO#read with internal encoding specified by internal_encoding: option returns a transcoded String" # Exception: Unsupported encoding label "euc-jp"
  fails "IO#read with internal encoding specified by internal_encoding: option sets the String encoding to the internal encoding" # Exception: Unsupported encoding label "euc-jp"
  fails "IO#read with internal encoding specified by mode: option returns a transcoded String" # Exception: Unsupported encoding label "euc-jp"
  fails "IO#read with internal encoding specified by mode: option sets the String encoding to the internal encoding" # Exception: Unsupported encoding label "euc-jp"
  fails "IO#read with internal encoding specified by open mode returns a transcoded String" # Exception: Unsupported encoding label "euc-jp"
  fails "IO#read with internal encoding specified by open mode sets the String encoding to the internal encoding" # Exception: Unsupported encoding label "euc-jp"
  fails "IO#readchar with internal encoding not specified does not transcode the String" # Exception: Unsupported encoding label "euc-jp"
  fails "IO#readchar with internal encoding not specified sets the String encoding to the external encoding" # Exception: Unsupported encoding label "euc-jp"
  fails "IO#readchar with internal encoding specified by encoding: option returns a transcoded String" # Exception: Unsupported encoding label "euc-jp"
  fails "IO#readchar with internal encoding specified by encoding: option sets the String encoding to the internal encoding" # Exception: Unsupported encoding label "euc-jp"
  fails "IO#readchar with internal encoding specified by internal_encoding: option returns a transcoded String" # Exception: Unsupported encoding label "euc-jp"
  fails "IO#readchar with internal encoding specified by internal_encoding: option sets the String encoding to the internal encoding" # Exception: Unsupported encoding label "euc-jp"
  fails "IO#readchar with internal encoding specified by mode: option returns a transcoded String" # Exception: Unsupported encoding label "euc-jp"
  fails "IO#readchar with internal encoding specified by mode: option sets the String encoding to the internal encoding" # Exception: Unsupported encoding label "euc-jp"
  fails "IO#readchar with internal encoding specified by open mode returns a transcoded String" # Exception: Unsupported encoding label "euc-jp"
  fails "IO#readchar with internal encoding specified by open mode sets the String encoding to the internal encoding" # Exception: Unsupported encoding label "euc-jp"
  fails "IO#syswrite on a file does not modify the passed argument" # Expected [198, 32, 25] == [198, 146] to be truthy but was false
  fails "IO#write on a file writes binary data if no encoding is given and multiple arguments passed" # Expected [32, 33, 196, 32, 38] == [135, 196, 133] to be truthy but was false
end
