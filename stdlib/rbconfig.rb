module RbConfig
  versions = RUBY_VERSION.split('.')
  CONFIG = {
    'ruby_version' => RUBY_VERSION,
    'MAJOR'        => versions[0],
    'MINOR'        => versions[1],
    'TEENY'        => versions[2],
    'RUBY'         => RUBY_ENGINE,
    'RUBY_INSTALL_NAME' => RUBY_ENGINE,
    'RUBY_SO_NAME'      => RUBY_ENGINE,
    'target_os'         => 'ECMA-262',
    'host_os'           => 'ECMA-262',
    'PATH_SEPARATOR'    => ':'
  }
end

# required for mspec it would appear
RUBY_NAME = 'opal'
RUBY_EXE = 'opal'
