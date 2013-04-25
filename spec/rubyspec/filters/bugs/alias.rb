opal_filter "alias keyword" do
  fails "The alias keyword operates on the object's metaclass when used in instance_eval"
  fails "The alias keyword operates on methods defined via attr, attr_reader, and attr_accessor"
  fails "The alias keyword operates on methods with splat arguments defined in a superclass using text block for class eval"
  fails "The alias keyword is not allowed against Fixnum or String instances"
end
