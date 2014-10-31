require 'spec_helper'
require 'date'

# rubyspec does not have specs for these listed methods
describe Date do
  describe ".parse" do
    it "parses a date string into a Date instance" do
      Date.parse('2013-10-4').should == Date.new(2013, 10, 4)
      Date.parse('2013-06-02').should == Date.new(2013, 6, 2)
    end
  end

  describe "#<" do
    it "is true when self is before other" do
      (Date.new(2013, 2, 4) < Date.new(2013, 2, 5)).should == true
      (Date.new(2013, 2, 4) < Date.new(2014, 7, 6)).should == true
    end

    it "is false when self is not before other" do
      (Date.new(2013, 2, 4) < Date.new(2013, 2, 4)).should == false
      (Date.new(2014, 2, 4) < Date.new(2013, 7, 6)).should == false
    end
  end

  describe '#<=' do
    it "is true when self is before or the same day as other" do
      (Date.new(2013, 4, 5) <= Date.new(2013, 4, 5)).should == true
      (Date.new(2013, 4, 5) <= Date.new(2013, 4, 9)).should == true
    end

    it "is false when self is after other" do
      (Date.new(2013, 4, 5) <= Date.new(2013, 4, 2)).should == false
      (Date.new(2013, 4, 5) <= Date.new(2013, 2, 5)).should == false
    end
  end

  describe "#==" do
    it "returns true if self is equal to other date" do
      (Date.new(2013, 9, 13) == Date.new(2013, 9, 13)).should == true
    end

    it "returns false if self is not equal to other date" do
      (Date.new(2013, 10, 2) == Date.new(2013, 10, 11)).should == false
    end
  end

  describe "#clone" do
    it "creates a copy of the current date" do
      orig = Date.new(2013, 10, 15)
      copy = orig.clone

      orig.should == copy
      orig.object_id.should_not == copy.object_id
    end
  end

  describe "#day" do
    it "returns the day of the date" do
      Date.new(2013, 2, 10).day.should == 10
      Date.new(2013, 2, 1).day.should == 1
    end
  end

  describe "#month" do
    it "returns the month of the date" do
      Date.new(2013, 1, 23).month.should == 1
      Date.new(2013, 12, 2).month.should == 12
    end
  end

  describe "#next" do
    it "returns the next date from self" do
      Date.new(2013, 4, 6).next.should == Date.new(2013, 4, 7)
      Date.new(2013, 6, 30).next.should == Date.new(2013, 7, 1)
      Date.new(2013, 12, 31).next.should == Date.new(2014, 1, 1)
    end
  end

  describe "#next_month" do
    it "returns the date with the next calendar month to self" do
      Date.new(2013, 2, 5).next_month.should == Date.new(2013, 3, 5)
      Date.new(2013, 5, 31).next_month.should == Date.new(2013, 6, 30)
      Date.new(2013, 12, 5).next_month.should == Date.new(2014, 1, 5)
    end
  end

  describe "#prev_month" do
    it "returns the date with the previous calendar month" do
      Date.new(2013, 2, 9).prev_month.should == Date.new(2013, 1, 9)
      Date.new(2013, 7, 31).prev_month.should == Date.new(2013, 6, 30)
      Date.new(2013, 1, 3).prev_month.should == Date.new(2012, 12, 3)
    end
  end

  describe '#next_day' do
    it 'returns a new date the given number of days after self' do
      Date.new(2014, 4, 5).next_day.should == Date.new(2014, 4, 6)
      Date.new(2014, 4, 5).next_day(4).should == Date.new(2014, 4, 9)
    end
  end

  describe '#prev_day' do
    it 'returns the date the given number of days before self' do
      Date.new(2014, 4, 5).prev_day.should == Date.new(2014, 4, 4)
      Date.new(2014, 4, 5).prev_day(4).should == Date.new(2014, 4, 1)
    end
  end

  describe '#succ' do
    it 'returns the date after the receiver' do
      Date.new(1986, 5, 26).succ.should == Date.new(1986, 5, 27)
    end
  end

  describe "#to_s" do
    it "returns an ISO 8601 representation" do
      Date.new(2013, 10, 15).to_s.should == "2013-10-15"
      Date.new(2013, 4, 9).to_s.should == "2013-04-09"
    end
  end

  describe "#wday" do
    it "returns the day of the week" do
      Date.new(2001, 2, 3).wday.should == 6
      Date.new(2001, 2, 4).wday.should == 0
    end
  end

  describe "#year" do
    it "returns the year as an integer" do
      Date.new(2013, 2, 9).year.should == 2013
    end
  end

  it 'correctly reports mondays' do
    Date.new(2015, 4, 6).monday?.should be_true
  end

  it 'correctly reports tuesdays' do
    Date.new(2015, 4, 7).tuesday?.should be_true
  end

  it 'correctly reports wednesdays' do
    Date.new(2015, 4, 8).wednesday?.should be_true
  end

  it 'correctly reports thursdays' do
    Date.new(2015, 4, 9).thursday?.should be_true
  end

  it 'correctly reports fridays' do
    Date.new(2015, 4, 10).friday?.should be_true
  end

  it 'correctly reports saturdays' do
    Date.new(2015, 4, 11).saturday?.should be_true
  end

  it 'correctly reports sundays' do
    Date.new(2015, 4, 12).sunday?.should be_true
  end

end
