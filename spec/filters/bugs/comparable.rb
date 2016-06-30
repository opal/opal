opal_filter "Comparable" do
  fails "Comparable#== when #<=> raises an exception if it is a StandardError lets it go through"
  fails "Comparable#== when #<=> raises an exception if it is a subclass of StandardError lets it go through"
  fails "Comparable#== when #<=> returns nor nil neither an Integer raises an ArgumentError"
end
