require 'bundler/setup'
Bundler.require(:default)

# for mspec
Opal.append_path(File.realdirpath('opal'))
Opal.append_path(File.realdirpath('../../spec/mspec/lib'))
Opal.append_path(File.realdirpath('../../spec'))

# for minitest
Opal.append_path(File.realdirpath('../../test'))
Opal.append_path(File.realdirpath('../../vendored-minitest'))
Opal.append_path(File.realdirpath('../../test/cruby/test'))
