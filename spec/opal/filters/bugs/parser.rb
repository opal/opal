opal_filter "Opal::Parser" do
  fails "Singleton classes returns an empty s(:scope) when given an empty body"
  fails "Singleton classes should accept any expressions for singleton part"
  fails "Strings from %Q construction should match '{' and '}' pairs used to start string before ending match"
  fails "Strings from %Q construction should match '(' and ')' pairs used to start string before ending match"
  fails "Strings from %Q construction should match '[' and ']' pairs used to start string before ending match"
  fails "x-strings created using %x notation should match '{' and '}' pairs used to start string before ending match"
  fails "x-strings created using %x notation should match '(' and ')' pairs used to start string before ending match"
  fails "x-strings created using %x notation should match '[' and ']' pairs used to start string before ending match"
end
