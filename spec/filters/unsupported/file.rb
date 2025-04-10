# NOTE: run bin/format-filters after changing this file
opal_unsupported_filter "File" do
  fails "File.join doesn't mutate the object when calling #to_str" # Mock 'usr' expected to receive to_str("any_args") exactly 1 times but received it 0 times
end
