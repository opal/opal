opal_filter "Struct" do
  fails "Struct#eql? handles recursive structures by returning false if a difference can be found"
  fails "Struct#== handles recursive structures by returning false if a difference can be found"
  fails "Struct#members does not override the instance accessor method"
  fails "Struct includes Enumerable"
  fails "Struct anonymous class instance methods includes Enumerable"
end
