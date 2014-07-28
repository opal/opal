require 'support/parser_helpers'

describe Opal::Parser do
  describe '-@NUM' do
    context 'with an integer' do
      it "parses unary op. with the right precedence" do
        parsed("-1.hello").should == [
          :call, [
            :call, [
              :int, 1
            ], :-@, [
              :arglist
            ]
          ], :hello, [
            :arglist
          ]
        ]
      end

      it "parses unary op. as a method call" do
        parsed("-1").should == [
          :call, [
            :int, 1
          ], :-@, [
            :arglist
          ]
        ]
      end

    end

    context 'with a float' do
      it "parses unary op. with the right precedence" do
        parsed("-1.23.hello").should == [
          :call, [
            :call, [
              :float, 1.23
            ], :-@, [
              :arglist
            ]
          ], :hello, [
            :arglist
          ]
        ]
      end

      it "parses unary op. as a method call" do
        parsed("-1.23").should == [
          :call, [
            :float, 1.23
          ], :-@, [
            :arglist
          ]
        ]
      end

    end
  end
end
