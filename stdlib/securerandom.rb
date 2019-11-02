module SecureRandom
  def self.hex(count)
    %x{
      var repeat = Math.floor(count / 6),
          remain = count % 6,
          string = '';

      for (var i = 0; i < repeat; i++) {
        string = string + Math.floor(Math.random()*parseInt('ff'.repeat(6), 16)).toString(16);
      }
      if (remain > 0) {
        string = string + Math.floor(Math.random()*parseInt('ff'.repeat(remain), 16)).toString(16);
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
