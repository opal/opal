# NOTE: run bin/format-filters after changing this file
opal_filter "Marshal" do
  fails "Marshal.load for a Time keeps the local zone" # Expected "Mitteleuropäische Sommerzeit" == "Mitteleuropäische Normalzeit" to be truthy but was false
end
