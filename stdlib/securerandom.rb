module SecureRandom
  def self.hex(count = nil)
    count ||= 16
    count = count.to_int unless `typeof count === "number"`
    raise ArgumentError, 'count of hex numbers must be positive' if count < 0
    %x{
      count = Math.floor(count);
      var repeat = Math.floor(count / 6),
          remain = count % 6,
          remain_total = remain * 2,
          string = '',
          temp;
      for (var i = 0; i < repeat; i++) {
        // parseInt('ff'.repeat(6), 16) == 281474976710655
        temp = Math.floor(Math.random() * 281474976710655).toString(16);
        if (temp.length < 12) {
          // account for leading zeros gone missing
          temp = '0'.repeat(12 - temp.length) + temp;
        }
        string = string + temp;
      }
      if (remain > 0) {
        temp = Math.floor(Math.random()*parseInt('ff'.repeat(remain), 16)).toString(16);
        if (temp.length < remain_total) {
          // account for leading zeros gone missing
          temp = '0'.repeat(remain_total - temp.length) + temp;
        }
        string = string + temp;
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
