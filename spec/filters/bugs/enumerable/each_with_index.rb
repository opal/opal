opal_filter "Enumerable#each_with_index" do
  fails "Enumerable#each_with_index provides each element to the block"
  fails "Enumerable#each_with_index provides each element to the block and its index"
  fails "Enumerable#each_with_index binds splat arguments properly"
  fails "Enumerable#each_with_index passes extra parameters to each"
end
