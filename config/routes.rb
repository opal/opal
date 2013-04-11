Rails.application.routes.draw do
  get '/opal_spec' => 'opal_spec#run' if %w[test development].include? Rails.env
end
