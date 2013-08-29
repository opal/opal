module SecureRandom
  def self.uuid
    "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx".gsub /[xy]/ do |ch,|
      %x{
        var r = Math.random() * 16 | 0,
            v = ch == "x" ? r : (r & 3 | 8);

        return v.toString(16);
      }
    end
  end
end
