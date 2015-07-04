opal_filter "Comparable" do
  fails "Comparable#== when #<=> is not defined returns false and does not recurse infinitely"
  fails "Comparable#== when #<=> calls super calls the defined #<=> only once for different objects"
end
