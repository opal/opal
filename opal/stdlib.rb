-*- mode: compilation; default-directory: "~/experiments/httpd/libraries/" -*-
Compilation started at Sat Jul  2 07:10:09

make -B -k t3
ruby -I /home/mdupont/experiments/opal/lib/ /home/mdupont/experiments/opal/bin/opal \
--compile \
--debug \
--verbose  \
--file testout.js  \
-I /home/mdupont/experiments/httpd/libraries -I /home/mdupont/experiments/logger/lib/ -I /home/mdupont/experiments/ffi-yajl/lib -I /home/mdupont/experiments/chef/lib -I /home/mdupont/experiments/chef/chef-config/lib -I /home/mdupont/experiments/ohai/lib -I /home/mdupont/experiments/mixlib-authentication/lib -I /home/mdupont/experiments/mixlib-shellout/lib -I /home/mdupont/experiments/mixlib-log/lib -I /home/mdupont/experiments/mixlib-config/lib -I /home/mdupont/experiments/syslog_logger/lib -I /home/mdupont/experiments/fuzzyurl.rb/lib -I /home/mdupont/experiments/compat_resource/files/lib -I /home/mdupont/experiments/ffi/lib -I/home/mdupont/experiments/chef/chef-config/lib/chef-config -I /home/mdupont/experiments/chef/lib/chef/log \
/home/mdupont/experiments/httpd/libraries/test.rb  >testout2.js
WARNING: Cannot handle dynamic require -- ffi:4
nodejs testout2.js
Object freezing is not supported by Opal

/home/mdupont/experiments/httpd/libraries/testout2.js:4949
      throw exception;
      ^
exist?: undefined method `exist?' for FileTest
    at Opal.defs.TMP_1 [as $new] (/home/mdupont/experiments/httpd/libraries/testout2.js:5239:15)
    at module_constructor.ːmethod_missing (/home/mdupont/experiments/httpd/libraries/testout2.js:3671:54)
    at module_constructor.method_missing_stub [as $exist?] (/home/mdupont/experiments/httpd/libraries/testout2.js:1082:35)
    at $LocklessLogDevice.ːopen_logfile (/home/mdupont/experiments/httpd/libraries/testout2.js:52274:53)
    at $LocklessLogDevice.ːinitialize (/home/mdupont/experiments/httpd/libraries/testout2.js:52157:27)
    at Opal.defn.TMP_4 [as $new] (/home/mdupont/experiments/httpd/libraries/testout2.js:3371:23)
    at $MonoLogger.ːinitialize (/home/mdupont/experiments/httpd/libraries/testout2.js:52130:63)
    at Opal.defn.TMP_4 [as $new] (/home/mdupont/experiments/httpd/libraries/testout2.js:3371:23)
    at /home/mdupont/experiments/httpd/libraries/testout2.js:65748:43
    at /home/mdupont/experiments/httpd/libraries/testout2.js:65806:7
Makefile:8: recipe for target 't3' failed
make: *** [t3] Error 1

Compilation exited abnormally with code 2 at Sat Jul  2 07:10:34
