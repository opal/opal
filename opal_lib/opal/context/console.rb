module Opal
  class Console

    def log(*str)
      puts str.join("\n")
      nil
    end
  end
end

