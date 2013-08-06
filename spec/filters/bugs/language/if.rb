opal_filter "if" do
  fails "The if expression with a boolean range ('flip-flop' operator) keeps flip-flops from interfering"
  fails "The if expression with a boolean range ('flip-flop' operator) scopes state by flip-flop"
  fails "The if expression with a boolean range ('flip-flop' operator) evaluates the second conditions lazily with exclusive-end range"
  fails "The if expression with a boolean range ('flip-flop' operator) evaluates the second conditions lazily with inclusive-end range"
  fails "The if expression with a boolean range ('flip-flop' operator) evaluates the first conditions lazily with exclusive-end range"
  fails "The if expression with a boolean range ('flip-flop' operator) evaluates the first conditions lazily with inclusive-end range"
  fails "The if expression with a boolean range ('flip-flop' operator) allows combining two flip-flops"
  fails "The if expression with a boolean range ('flip-flop' operator) mimics a sed conditional with a many-element exclusive-end range"
  fails "The if expression with a boolean range ('flip-flop' operator) mimics a sed conditional with a zero-element exclusive-end range"
  fails "The if expression with a boolean range ('flip-flop' operator) mimics an awk conditional with a many-element inclusive-end range"
  fails "The if expression with a boolean range ('flip-flop' operator) mimics an awk conditional with a single-element inclusive-end range"
end
