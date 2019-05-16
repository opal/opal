require 'bundler/setup'
# change OWL_ENV to the projects name env, like MY_PROJECT_ENV
env_name = 'OWL_ENV'
if ENV[env_name] && ENV[env_name] == 'test'
  Bundler.require(:default, :test)
elsif ENV[env_name] && ENV[env_name] == 'production'
  Bundler.require(:default, :production)
else
  Bundler.require(:default, :development)
end
Opal.append_path(File.realdirpath('opal'))
Opal.append_path(File.realdirpath('../../spec/mspec/lib'))
Opal.append_path(File.realdirpath('../../spec'))
