describe "Opal::Parser" do
  it "should parse simple ruby values" do
    opal_eval('3.142').should == 3.142
    opal_eval('false').should == false
    opal_eval('true').should == true
    opal_eval('nil').should == nil
  end

  it "should parse ruby strings" do
    opal_eval('"hello world"').should == "hello world"
    opal_eval('"hello #{100}"').should == "hello 100"
  end

  it "should parse method calls" do
    opal_eval("[1, 2, 3, 4].inspect").should == "[1, 2, 3, 4]"
    opal_eval("[1, 2, 3, 4].map { |a| a + 42 }").should == [43, 44, 45, 46]
  end

  it "should parse constant lookups" do
    opal_eval("Object").should == Object
    opal_eval("Array").should == Array
    opal_eval("OpalSpec::ExampleGroup").should == OpalSpec::ExampleGroup
  end

  it "should parse class and module definitions" do
    opal_eval("class ParserModuleDefinition; end")
    opal_eval <<-STR
      class ParserClassDefinition
        CONSTANT = 500

        def foo
          500
        end

        def self.bar
          42
        end
      end
    STR

    ParserClassDefinition.bar.should == 42
    ParserClassDefinition.new.foo.should == 500
  end
end