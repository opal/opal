opal_filter "case" do
  fails "The 'case'-construct lets you define a method after the case statement"
  fails "The 'case'-construct with no target expression evaluates the body of the first clause when at least one of its condition expressions is true"
  fails "The 'case'-construct with no target expression evaluates the body of the first when clause that is not false/nil"
  fails "The 'case'-construct with no target expression evaluates the body of the else clause if all when clauses are false/nil"
  fails "The 'case'-construct with no target expression evaluates multiple conditional expressions as a boolean disjunction"
  fails "The 'case'-construct with no target expression evaluates true as only 'true' when true is the first clause"
end
