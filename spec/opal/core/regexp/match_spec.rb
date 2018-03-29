describe 'Regexp#match' do
  describe 'when pos is not specified' do
    it 'calls .exec only once on the current object' do
      regexp = /test/
      calls = 0
      %x(
        regexp._exec = regexp.exec;
        regexp.exec = function(str) {
          var match = this._exec(str);
          calls++;
          return match;
        }
      )
      result = regexp.match('test test')
      calls.should == 1
      result.begin(0).should == 0
      result[0].should == 'test'
    end
  end

  describe 'when pos is specified' do
    it 'does not call .exec on the current object' do
      regexp = /test/
      calls = 0
      %x(
        regexp._exec = regexp.exec;
        regexp.exec = function(str) {
          var match = this._exec(str);
          calls++;
          return match;
        }
      )
      result = regexp.match('test test', 1)
      calls.should == 0
      result[0].should == 'test'
      result.begin(0).should == 5
    end
  end
end

describe 'Regexp#match?' do
  describe 'when pos is not specified' do
    it 'calls .test on the current object' do
      regexp = /test/
      calls = 0
      %x(
        regexp._test = regexp.test;
        regexp.test = function(str) {
          var verdict = this._test(str);
          calls++;
          return verdict;
        }
      )
      result = regexp.match?('test test')
      calls.should == 1
      result.should == true
    end
  end

  describe 'when pos is specified' do
    it 'does not call .test on the current object' do
      regexp = /test/
      calls = 0
      %x(
        regexp._test = regexp.test;
        regexp.test = function(str) {
          var verdict = this._test(str);
          calls++;
          return verdict;
        }
      )
      result = regexp.match?('test test', 1)
      calls.should == 0
      # FIXME pos is not yet supported by Opal's Regexp#match?
      #result.should == true
    end
  end
end
