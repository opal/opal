require 'spec_helper'

describe "IO reading methods" do
  examples = [
    "abc\n|def\n|ghi\n",
    "ab|c\nd|ef\n|ghi\n",
    "©©©\n|ŋææ\n|æπ®\n",
    "🫃🫃🫃\n|🫃🫃🫃\n|🫃🫃🫃\n",
    "efhasdfhasf|asdfasdfasdf|asdfasdfasdf",
    "gsdfgsdg🫃|🫃🫃\n|🫃",
    "a\nb\nc\nd\ne\nf",
    "abcððefsdf🫃|s\nd",
    "a|b|c|d|e|f|g|h|i|\n|j|k|l|\n",
    "a b\n|c| d\n|e f",
    "",
    "asdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfsafsdsdf\nsadfasdf"
  ]
  examples += examples.map { |i| i.gsub("\n", "\r\n") }
  examples += examples.map { |i| i.gsub("\n", "\r|\n") }
  examples = examples.uniq

  prepare_io_for = proc do |example|
    example_lines = example.split("|")
    file_name = if Dir.exist?('../tmp')
                  # accessing the real filesystem
                  '../tmp/read_spec_tmp_file'
                else
                  # acessing the virtual file system in browsers
                  'tmp/read_spec_tmp_file'
                end

    File.delete(file_name) rescue nil
    fd = IO.sysopen(file_name, 'w+')
    io = IO.new(fd, 'w+')
    io.write(*example_lines)
    io.rewind
    io
  end

  describe "#readlines" do
    examples.each do |example|
      it "correctly splits messages for input #{example.inspect}" do
        io = prepare_io_for.(example)
        expected_output = example.gsub("|", "").split(/\n/).map { |e| e + "\n" }
        len = expected_output.length
        last = expected_output.last
        expected_output[len-1] = last.chop if !example.end_with?("\n") && last
        expected_output.should == io.readlines
      end
    end
  end

  describe "#readline" do
    examples.each do |example|
      it "correctly splits messages for input #{example.inspect}" do
        io = prepare_io_for.(example)
        expected_output = example.gsub("|", "").split(/\n/).map { |e| e + "\n" }
        len = expected_output.length
        last = expected_output.last
        expected_output[len-1] = last.chop if !example.end_with?("\n") && last
        loop do
          expected_output.shift.should == io.readline
        rescue EOFError
          expected_output.should == []
          break
        end
      end
    end
  end

  describe "#gets" do
    examples.each do |example|
      it "correctly splits messages for input #{example.inspect}" do
        io = prepare_io_for.(example)
        expected_output = example.gsub("|", "").split(/\n/).map { |e| e + "\n" }
        len = expected_output.length
        last = expected_output.last
        expected_output[len-1] = last.chop if !example.end_with?("\n") && last
        loop do
          line = io.gets
          expected_output.shift.should == line
          break unless line
        end
      end
    end
  end
end
