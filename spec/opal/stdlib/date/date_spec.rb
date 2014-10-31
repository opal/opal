require 'date'

describe 'Date' do
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
