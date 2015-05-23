opal_filter "Method" do
  fails "Method#define_method when passed a Method object defines a method with the same #parameters as the original"
  fails "Method#define_method when passed an UnboundMethod object defines a method with the same #arity as the original"
  fails "Method#define_method when passed an UnboundMethod object defines a method with the same #parameters as the original"
end
