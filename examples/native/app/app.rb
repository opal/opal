require 'opal'

$global.addEventListener 'DOMContentLoaded', proc {

  css = <<-CSS
    body {
      font-family: 'Arial';
    }

    h1 {
      color: rgb(10, 94, 232);
    }
  CSS

  document = $global.document

  title = document.createElement 'h1'
  title.className = 'main-title'
  title.innerHTML = 'Opal Native Example'

  desc = document.createElement 'p'
  desc.innerHTML = "Hello world! From Opal."

  target = document.getElementById 'native-example'

  unless target
    raise "'native-example' doesn't exist?"
  end

  target.appendChild title
  target.appendChild desc

  styles = document.createElement 'style'
  styles.type = 'text/css'

  if styles.respond_to? :styleSheet
    styles.styleSheet.cssText = css
  else
    styles.appendChild document.createTextNode css
  end

  document.getElementsByTagName('head')[0].appendChild(styles)

}, false
