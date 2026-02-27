# NOTE: run bin/format-filters after changing this file
opal_unsupported_filter "Enumerator" do
  fails "Enumerator#rewind calls the enclosed object's rewind method if one exists" # Mock 'rewinder' expected to receive rewind("any_args") exactly 1 times but received it 0 times
  fails "Enumerator#rewind clears a pending #feed value" # NotImplementedError: Opal doesn't support Enumerator#feed  
end
