# need to require dependencies first
require 'json'

# alert() doesnt exist without rquery or opal-browser
def alert(msg)
  `window.alert(msg)`
end

json = <<-JSON
{
  "adam": null,
  "fred": [1, 2, 3],
  "bill": false
}
JSON

hash = JSON.parse json

alert hash.inspect