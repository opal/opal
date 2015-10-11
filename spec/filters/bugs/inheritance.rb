opal_filter "bridged inheritance" do
  fails "StringScanner#post_match returns an instance of String when passed a String subclass"
  fails "StringScanner#pre_match returns an instance of String when passed a String subclass"
  fails "StringScanner#rest returns an instance of String when passed a String subclass"
end
