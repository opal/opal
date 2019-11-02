module SecureRandom
  def self.hex(count = nil)
    count = 16 unless count
    count = count.to_int unless `typeof count === "number"`
    raise ArgumentError, "count of hex numbers must be positive" if count < 0
    %x{
      count = Math.floor(count);
      var repeat = Math.floor(count / 6),
          remain = count % 6,
          total = count * 2,
          string = '';

      for (var i = 0; i < repeat; i++) {
        string = string + Math.floor(Math.random()*parseInt('ff'.repeat(6), 16)).toString(16);
      }
      if (remain > 0) {
        string = string + Math.floor(Math.random()*parseInt('ff'.repeat(remain), 16)).toString(16);
      }
      remain = total - string.length;
      if (remain > 0) {
        // account for leading zeros gone missing
        string = '0'.repeat(remain) + string;
      } else if (remain < 0) {
        // account for overruns
        string = string.slice(total - 1);
      }
      return string;
    }
  end

  def self.uuid
    'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.gsub(/[xy]/) do |ch,|
      %x{
        var r = Math.random() * 16 | 0,
            v = ch == "x" ? r : (r & 3 | 8);

        return v.toString(16);
      }
    end
  end
end
