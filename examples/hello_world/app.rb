# Without rquery or opal-browser, opal doesn't know about the browser
def alert(msg)
  `window.alert(msg)`
end

# Alert a simple message
alert "Hello World!"