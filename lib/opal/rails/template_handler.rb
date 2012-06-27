module Opal
  module Rails
    class TemplateHandler
      def self.call(template)
        escaped = template.source.gsub(':', '\:')
        string = '%q:' + escaped + ':;'
        "Opal.parse(#{string})"
      end
    end
  end
end

ActiveSupport.on_load(:action_view) do
  ActionView::Template.register_template_handler :opal, Opal::Rails::TemplateHandler
  ActionView::Template.register_template_handler :rb, Opal::Rails::TemplateHandler
end
