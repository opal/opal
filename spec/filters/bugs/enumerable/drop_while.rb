opal_filter "Enumerable#drop_while" do
  fails "Enumerable#drop_while returns an Enumerator if no block given"
  fails "Enumerable#drop_while passes elements to the block until the first false"
  fails "Enumerable#drop_while will only go through what's needed"
  fails "Enumerable#drop_while gathers whole arrays as elements when each yields multiple"
end
