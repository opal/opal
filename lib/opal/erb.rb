require 'opal/parser'

module Opal
  module ERB
    def self.parse(str, name='(erb)')
      body = str.gsub('"', '\\"').gsub(/<%=([\s\S]+?)%>/) do
        inner = $1.gsub(/\\'/, "'").gsub(/\\"/, '"')
        "\")\nout.<<(#{ inner })\nout.<<(\""
      end.gsub(/<%([\s\S]+?)%>/) do
        "\")\n#{ $1 }\nout.<<(\""
      end

      code = "ERB.new('#{name}') do |out|\nout.<<(\"#{ body }\")\nout.join\nend\n"
      Opal.parse code
    end
  end
end
