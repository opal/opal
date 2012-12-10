module Opal
  def self.parse_erb(str, name = '(erb)')
    body = str.gsub('"', '\\"').gsub(/<%=([\s\S]+?)%>/) do
      inner = $1.gsub(/\\'/, "'").gsub(/\\"/, '"')
      "\")\nout.<<(#{ inner })\nout.<<(\""
    end.gsub(/<%([\s\S]+?)%>/) do
      "\")\n#{ $1 }\nout.<<(\""
    end

    code = "ERB.new('#{name}') do\nout = []\nout.<<(\"#{ body }\")\nout.join\nend\n"
    "// #{ name } (erb)\n#{ Opal.parse(code) }\n"
  end
end

