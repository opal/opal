opal_unsupported_filter "Random" do
  fails "Random#bytes returns the same numeric output for a given seed accross all implementations and platforms"
  fails "Random#bytes returns the same numeric output for a given huge seed accross all implementations and platforms"
end
