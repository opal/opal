module LiteralLambdaMethods
  SOME_CONSTANT = "some value"
  def self.literal_lambda_with_constant
    ->{SOME_CONSTANT}
  end
  # module_function :literal_lambda_with_constant
end
