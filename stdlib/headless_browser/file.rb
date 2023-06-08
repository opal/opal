# frozen_string_literal: true
# backtick_javascript: true

class File
  def self.write(path, data)
    # This is only to enable CDP runners to write the benchmark results
    %x{
      var http = new XMLHttpRequest();
      http.open("POST", "/File.write");
      http.setRequestHeader("Content-Type", "application/json");
      // Failure is not an option
      http.send(JSON.stringify({filename: #{path}, data: #{data}, secret: window.OPAL_CDP_SHARED_SECRET}));
    }
    data.length
  end
end
