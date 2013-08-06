opal_filter "Array#rassoc" do
  fails "Array#rassoc does not check the last element in each contained but speficically the second"
  fails "Array#rassoc calls elem == obj on the second element of each contained array"
end
