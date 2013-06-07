require 'opal'

# We can treat native objects (in this case `window`) as a ruby object
# and open up a singleton class on it and define methods on the object
# directly. This basically defines just a single ruby method onto
# `window`.
class << $global

  # on_ready is a simple method that just adds a 'DOMContentLoaded'
  # event onto window. `self` inside this method will be `window`,
  # so we can call addEventListener as we would in ruby
  def on_ready(&block)
    addEventListener 'DOMContentLoaded', block, false
  end
end

# Call our new method on window (which is accessed by `$global`
$global.on_ready do
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
end
