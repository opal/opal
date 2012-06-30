Rails.application.routes.draw do
  match '/opal_spec' => 'opal_spec#run' if Rails.env.development?
end
