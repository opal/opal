require 'spec_helper'
require 'date'

# rubyspec does not have specs for these listed methods
describe Date do
  describe ".parse" do
    it "parses a date string into a Date instance" do
      expect(Date.parse('2013-10-4')).to eq(Date.new(2013, 10, 4))
      expect(Date.parse('2013-06-02')).to eq(Date.new(2013, 6, 2))
    end
  end

  describe "#<" do
    it "is true when self is before other" do
      expect(Date.new(2013, 2, 4) < Date.new(2013, 2, 5)).to eq(true)
      expect(Date.new(2013, 2, 4) < Date.new(2014, 7, 6)).to eq(true)
    end

    it "is false when self is not before other" do
      expect(Date.new(2013, 2, 4) < Date.new(2013, 2, 4)).to eq(false)
      expect(Date.new(2014, 2, 4) < Date.new(2013, 7, 6)).to eq(false)
    end
  end

  describe '#<=' do
    it "is true when self is before or the same day as other" do
      expect(Date.new(2013, 4, 5) <= Date.new(2013, 4, 5)).to eq(true)
      expect(Date.new(2013, 4, 5) <= Date.new(2013, 4, 9)).to eq(true)
    end

    it "is false when self is after other" do
      expect(Date.new(2013, 4, 5) <= Date.new(2013, 4, 2)).to eq(false)
      expect(Date.new(2013, 4, 5) <= Date.new(2013, 2, 5)).to eq(false)
    end
  end

  describe "#==" do
    it "returns true if self is equal to other date" do
      expect(Date.new(2013, 9, 13) == Date.new(2013, 9, 13)).to eq(true)
    end

    it "returns false if self is not equal to other date" do
      expect(Date.new(2013, 10, 2) == Date.new(2013, 10, 11)).to eq(false)
    end
  end

  describe "#clone" do
    it "creates a copy of the current date" do
      orig = Date.new(2013, 10, 15)
      copy = orig.clone

      expect(orig).to eq(copy)
      expect(orig.object_id).not_to eq(copy.object_id)
    end
  end

  describe "#day" do
    it "returns the day of the date" do
      expect(Date.new(2013, 2, 10).day).to eq(10)
      expect(Date.new(2013, 2, 1).day).to eq(1)
    end
  end

  describe "#month" do
    it "returns the month of the date" do
      expect(Date.new(2013, 1, 23).month).to eq(1)
      expect(Date.new(2013, 12, 2).month).to eq(12)
    end
  end

  describe "#next" do
    it "returns the next date from self" do
      expect(Date.new(2013, 4, 6).next).to eq(Date.new(2013, 4, 7))
      expect(Date.new(2013, 6, 30).next).to eq(Date.new(2013, 7, 1))
      expect(Date.new(2013, 12, 31).next).to eq(Date.new(2014, 1, 1))
    end
  end

  describe "#next_month" do
    it "returns the date with the next calendar month to self" do
      expect(Date.new(2013, 2, 5).next_month).to eq(Date.new(2013, 3, 5))
      expect(Date.new(2013, 5, 31).next_month).to eq(Date.new(2013, 6, 30))
      expect(Date.new(2013, 12, 5).next_month).to eq(Date.new(2014, 1, 5))
    end
  end

  describe "#prev" do
    it "returns the previous date from self" do
      expect(Date.new(2013, 3, 5).prev).to eq(Date.new(2013, 3, 4))
      expect(Date.new(2013, 6, 1).prev).to eq(Date.new(2013, 5, 31))
      expect(Date.new(2014, 1, 1).prev).to eq(Date.new(2013, 12, 31))
    end
  end

  describe "#prev_month" do
    it "returns the date with the previous calendar month" do
      expect(Date.new(2013, 2, 9).prev_month).to eq(Date.new(2013, 1, 9))
      expect(Date.new(2013, 7, 31).prev_month).to eq(Date.new(2013, 6, 30))
      expect(Date.new(2013, 1, 3).prev_month).to eq(Date.new(2012, 12, 3))
    end
  end

  describe "#to_s" do
    it "returns an ISO 8601 representation" do
      expect(Date.new(2013, 10, 15).to_s).to eq("2013-10-15")
      expect(Date.new(2013, 4, 9).to_s).to eq("2013-04-09")
    end
  end

  describe "#wday" do
    it "returns the day of the week" do
      expect(Date.new(2001, 2, 3).wday).to eq(6)
      expect(Date.new(2001, 2, 4).wday).to eq(0)
    end
  end

  describe "#year" do
    it "returns the year as an integer" do
      expect(Date.new(2013, 2, 9).year).to eq(2013)
    end
  end
end
