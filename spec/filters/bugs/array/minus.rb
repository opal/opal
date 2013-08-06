opal_filter "Array#-" do
  fails "Array#- removes an identical item even when its #eql? isn't reflexive"
  fails "Array#- doesn't remove an item with the same hash but not #eql?"
  fails "Array#- removes an item identified as equivalent via #hash and #eql?"
end
