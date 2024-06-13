# backtick_javascript: true

describe "Array#include" do
  it "should respect nil values" do
    nileq = Object.new
    def nileq.==(other)
      nil
    end

    [nileq].should_not include("no match expected")
  end
end
