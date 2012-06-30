Rails.application.routes.draw do
  match '/opal_spec' => 'opal_spec#run' if %w[test development].include? Rails.env
end
