module Haml::Filters::Opal
  include Haml::Filters::Base

  def render_with_options ruby, options
    text = ::Opal.parse(ruby)
    
    if options[:format] == :html5
      type = ''
    else
      type = " type=#{options[:attr_wrapper]}text/javascript#{options[:attr_wrapper]}"
    end
    
    text.rstrip!
    text.gsub!("\n", "\n    ")
    
    <<HTML
<script#{type}>
  //<![CDATA[
    #{text}
  //]]>
</script>
HTML
  end
end
