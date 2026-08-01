# frozen_string_literal: true

require 'shellwords'
require 'socket'
require 'timeout'
require 'tmpdir'
require 'rbconfig'
require 'opal/os'
require 'json'
require 'fileutils'
require 'net/http'

module Opal
  module CliRunners
    class Firefox
      SCRIPT_PATH = File.expand_path('cdp_interface.rb', __dir__).freeze

      DEFAULT_CDP_HOST = 'localhost'
      DEFAULT_CDP_PORT = 9333 # makes sure it doesn't accidentally connect to a lingering chrome

      def self.call(data)
        runner = new(data)
        runner.run
      end

      def initialize(data)
        builder = data[:builder].call
        options = data[:options]
        argv    = data[:argv]

        if argv && argv.any?
          warn "warning: ARGV is not supported by the Firefox runner #{argv.inspect}"
        end

        @output  = options.fetch(:output, $stdout)
        @builder = builder
      end

      attr_reader :output, :exit_status, :builder

      def run
        mktmpdir do |dir|
          with_firefox_server do
            prepare_files_in(dir)

            env = {
              'OPAL_CDP_HOST' => chrome_host,
              'OPAL_CDP_PORT' => chrome_port.to_s,
              'NODE_PATH' => File.join(__dir__, 'node_modules')
            }
            env['OPAL_CDP_EXT'] = builder.output_extension

            cmd = [
              RbConfig.ruby,
              "#{__dir__}/../../../exe/opal",
              '--no-exit',
              '-I', __dir__,
              '-r', 'source-map-support-node',
              SCRIPT_PATH,
              dir
            ]

            Kernel.exec(env, *cmd)
          end
        end
      end

      private

      def prepare_files_in(dir)
        js = builder.to_s
        map = builder.source_map.to_json
        ext = builder.output_extension
        module_type = ' type="module"' if builder.esm?

        # CDP can't handle huge data passed to `addScriptToEvaluateOnLoad`
        # https://groups.google.com/a/chromium.org/forum/#!topic/chromium-discuss/U5qyeX_ydBo
        # The only way is to create temporary files and pass them to the browser.
        File.binwrite("#{dir}/index.#{ext}", js)
        File.binwrite("#{dir}/index.#{ext}.map", map)
        File.binwrite("#{dir}/index.html", <<~HTML)
          <!DOCTYPE html>
          <html><head>
            <meta charset='utf-8'>
            <link rel="shortcut icon" href="data:image/x-icon;," type="image/x-icon">
            <script>
            window.OPAL_EXIT_CODE = "noexit"
            </script>
          </head><body>
            <script src='/index.#{ext}'#{module_type}></script>
          </body></html>
        HTML
      end

      def chrome_host
        ENV['FIREFOX_HOST'] || ENV['OPAL_CDP_HOST'] || DEFAULT_CDP_HOST
      end

      def chrome_port
        ENV['FIREFOX_PORT'] || ENV['OPAL_CDP_PORT'] || DEFAULT_CDP_PORT
      end

      def with_firefox_server
        if firefox_server_running?
          yield
        else
          run_firefox_server { yield }
        end
      end

      def run_firefox_server
        raise 'Firefox server can be started only on localhost' if chrome_host != DEFAULT_CDP_HOST

        profile = mktmpprofile

        # For options see https://github.com/puppeteer/puppeteer/blob/main/packages/puppeteer-core/src/node/FirefoxLauncher.ts
        firefox_server_cmd = %{#{OS.shellescape(firefox_executable)} \
          --no-remote #{'--foreground' if OS.macos?} #{'--wait-for-browser' if OS.windows?} \
          --profile #{profile} \
          --headless \
          --remote-debugging-port #{chrome_port} \
          #{ENV['FIREFOX_OPTS']}}

        firefox_pid = Process.spawn(firefox_server_cmd, in: OS.dev_null, out: OS.dev_null, err: OS.dev_null)

        Timeout.timeout(30) do
          loop do
            break if firefox_server_running?
            sleep 0.5
          end
        end

        yield
      rescue Timeout::Error
        puts 'Failed to start firefox server'
        puts 'Make sure that you have it installed and that its version is > 100'
        if !OS.windows? && !OS.macos?
          # The firefox executable within snap is in fact the snap executable which sets up paths and then calls the
          # real firefox executable. It also mistreats passed options and args and always tries to reuse a existing
          # instance. Thus firefox from snap, when called by this runner, will start with the wrong options, the
          # wrong profile and will fail to setup the remote debugging port
          puts 'When firefox is installed via snap, it cannot work correctly with this runner.'
          puts 'In that case, please uninstall firefox via snap and install firefox from a apt repo, see:'
          puts 'https://support.mozilla.org/en-US/kb/install-firefox-linux#w_install-firefox-deb-package-for-debian-based-distributions'
        end
        exit(1)
      ensure
        if OS.windows? && firefox_pid
          Process.kill('KILL', firefox_pid) unless system("taskkill /f /t /pid #{firefox_pid} >NUL 2>NUL")
        elsif firefox_pid
          Process.kill('HUP', firefox_pid)
        end
        FileUtils.rm_rf(profile) if profile
      end

      def firefox_server_running?
        puts "Connecting to #{chrome_host}:#{chrome_port}..."
        TCPSocket.new(chrome_host, chrome_port).close
        # Firefox CDP endpoints are initialized after the CDP port is ready
        # this causes first requests to fail
        # wait until the CDP endpoints are ready
        response = Net::HTTP.get_response('localhost', '/json/list', chrome_port)
        raise Errno::EADDRNOTAVAIL if response.code != '200'
        true
      rescue Errno::ECONNREFUSED, Errno::EADDRNOTAVAIL
        false
      end

      def firefox_executable
        ENV['MOZILLA_FIREFOX_BINARY'] ||
          if OS.windows?
            [
              'C:/Program Files/Mozilla Firefox/firefox.exe'
            ].each do |path|
              next unless File.exist? path
              return path
            end
          elsif OS.macos?
            [
              '/Applications/Firefox.app/Contents/MacOS/Firefox',
              '/Applications/Firefox.app/Contents/MacOS/firefox',
            ].each do |path|
              return path if File.exist? path
            end
          else
            %w[
              firefox
              firefox-esr
            ].each do |name|
              next unless system('sh', '-c', "command -v #{name.shellescape}", out: '/dev/null')
              return name
            end
            raise 'Cannot find firefox executable'
          end
      end

      def mktmpdir(&block)
        Dir.mktmpdir('firefox-opal-', &block)
      end

      def mktmpprofile
        # for prefs see https://github.com/puppeteer/puppeteer/blob/main/packages/browsers/src/browser-data/firefox.ts
        # and https://github.com/puppeteer/puppeteer/blob/main/packages/puppeteer-core/src/node/FirefoxLauncher.ts
        profile = Dir.mktmpdir('firefox-opal-profile-')
        default_prefs = {
          # Make sure Shield doesn't hit the network.
          'app.normandy.api_url': '',
          # Disable Firefox old build background check
          'app.update.checkInstallTime': false,
          # Disable automatically upgrading Firefox
          'app.update.disabledForTesting': true,
          # Increase the APZ content response timeout to 1 minute
          'apz.content_response_timeout': 60_000,
          # Prevent various error message on the console
          'browser.contentblocking.features.standard': '-tp,tpPrivate,cookieBehavior0,-cm,-fp',
          # Enable the dump function: which sends messages to the system console
          # https://bugzilla.mozilla.org/show_bug.cgi?id=1543115
          'browser.dom.window.dump.enabled': true,
          # Disable topstories
          'browser.newtabpage.activity-stream.feeds.system.topstories': false,
          # Always display a blank page
          'browser.newtabpage.enabled': false,
          # Background thumbnails in particular cause grief: and disabling
          # thumbnails in general cannot hurt
          'browser.pagethumbnails.capturing_disabled': true,
          # Disable safebrowsing components.
          'browser.safebrowsing.blockedURIs.enabled': false,
          'browser.safebrowsing.downloads.enabled': false,
          'browser.safebrowsing.malware.enabled': false,
          'browser.safebrowsing.passwords.enabled': false,
          'browser.safebrowsing.phishing.enabled': false,
          # Disable updates to search engines.
          'browser.search.update': false,
          # Do not restore the last open set of tabs if the browser has crashed
          'browser.sessionstore.resume_from_crash': false,
          # Skip check for default browser on startup
          'browser.shell.checkDefaultBrowser': false,
          # Disable newtabpage
          'browser.startup.homepage': 'about:blank',
          # Do not redirect user when a milstone upgrade of Firefox is detected
          'browser.startup.homepage_override.mstone': 'ignore',
          # Start with a blank page about:blank
          'browser.startup.page': 0,
          # Do not close the window when the last tab gets closed
          'browser.tabs.closeWindowWithLastTab': false,
          # Do not allow background tabs to be zombified on Android: otherwise for
          # tests that open additional tabs: the test harness tab itself might get unloaded
          'browser.tabs.disableBackgroundZombification': false,
          # Do not warn when closing all other open tabs
          'browser.tabs.warnOnCloseOtherTabs': false,
          # Do not warn when multiple tabs will be opened
          'browser.tabs.warnOnOpen': false,
          # Do not automatically offer translations, as tests do not expect this.
          'browser.translations.automaticallyPopup': false,
          # Disable the UI tour.
          'browser.uitour.enabled': false,
          # Turn off search suggestions in the location bar so as not to trigger
          # network connections.
          'browser.urlbar.suggest.searches': false,
          # Disable first run splash page on Windows 10
          'browser.usedOnWindows10.introURL': '',
          # Do not warn on quitting Firefox
          'browser.warnOnQuit': false,
          # Defensively disable data reporting systems
          'datareporting.healthreport.documentServerURI': 'http://localhost/dummy/healthreport/',
          'datareporting.healthreport.logging.consoleEnabled': false,
          'datareporting.healthreport.service.enabled': false,
          'datareporting.healthreport.service.firstRun': false,
          'datareporting.healthreport.uploadEnabled': false,
          # Do not show datareporting policy notifications which can interfere with tests
          'datareporting.policy.dataSubmissionEnabled': false,
          'datareporting.policy.dataSubmissionPolicyBypassNotification': true,
          # DevTools JSONViewer sometimes fails to load dependencies with its require.js.
          # This doesn't affect Puppeteer but spams console (Bug 1424372)
          'devtools.jsonview.enabled': false,
          # Disable popup-blocker
          'dom.disable_open_during_load': false,
          # Enable the support for File object creation in the content process
          # Required for |Page.setFileInputFiles| protocol method.
          'dom.file.createInChild': true,
          # Disable the ProcessHangMonitor
          'dom.ipc.reportProcessHangs': false,
          # Disable slow script dialogues
          'dom.max_chrome_script_run_time': 0,
          'dom.max_script_run_time': 0,
          # Only load extensions from the application and user profile
          # AddonManager.SCOPE_PROFILE + AddonManager.SCOPE_APPLICATION
          'extensions.autoDisableScopes': 0,
          'extensions.enabledScopes': 5,
          # Disable metadata caching for installed add-ons by default
          'extensions.getAddons.cache.enabled': false,
          # Disable installing any distribution extensions or add-ons.
          'extensions.installDistroAddons': false,
          # Disabled screenshots extension
          'extensions.screenshots.disabled': true,
          # Turn off extension updates so they do not bother tests
          'extensions.update.enabled': false,
          # Turn off extension updates so they do not bother tests
          'extensions.update.notifyUser': false,
          # Make sure opening about:addons will not hit the network
          'extensions.webservice.discoverURL': 'http://localhost/dummy/discoveryURL',
          # Temporarily force disable BFCache in parent (https://bit.ly/bug-1732263)
          'fission.bfcacheInParent': false,
          # Force all web content to use a single content process
          'fission.webContentIsolationStrategy': 0,
          # Allow the application to have focus even it runs in the background
          'focusmanager.testmode': true,
          # Disable useragent updates
          'general.useragent.updates.enabled': false,
          # Always use network provider for geolocation tests so we bypass the
          # macOS dialog raised by the corelocation provider
          'geo.provider.testing': true,
          # Do not scan Wifi
          'geo.wifi.scan': false,
          # No hang monitor
          'hangmonitor.timeout': 0,
          # Show chrome errors and warnings in the error console
          'javascript.options.showInConsole': true,
          # Disable download and usage of OpenH264: and Widevine plugins
          'media.gmp-manager.updateEnabled': false,
          # Disable the GFX sanity window
          'media.sanity-test.disabled': true,
          # Prevent various error message on the console
          'network.cookie.cookieBehavior': 0,
          # Disable experimental feature that is only available in Nightly
          'network.cookie.sameSite.laxByDefault': false,
          # Avoid cookie expiry date to be affected by server time, which can result in flaky tests.
          'network.cookie.useServerTime': false,
          # Do not prompt for temporary redirects
          'network.http.prompt-temp-redirect': false,
          # Disable speculative connections so they are not reported as leaking
          # when they are hanging around
          'network.http.speculative-parallel-limit': 0,
          # Do not automatically switch between offline and online
          'network.manage-offline-status': false,
          # Make sure SNTP requests do not hit the network
          'network.sntp.pools': 'localhost',
          # Disable Flash.
          'plugin.state.flash': 0,
          'privacy.trackingprotection.enabled': false,
          # To enable remote protocols use:
          #   const WEBDRIVER_BIDI_ACTIVE = 0x1;
          #   const CDP_ACTIVE = 0x2;
          # Enable only CDP for now
          'remote.active-protocols': 2,
          # Can be removed once Firefox 89 is no longer supported
          # https://bugzilla.mozilla.org/show_bug.cgi?id=1710839
          'remote.enabled': true,
          # Don't do network connections for mitm priming
          'security.certerrors.mitm.priming.enabled': false,
          # Local documents have access to all other local documents,
          # including directory listings
          'security.fileuri.strict_origin_policy': false,
          # Do not wait for the notification button security delay
          'security.notification_enable_delay': 0,
          # Ensure blocklist updates do not hit the network
          'services.settings.server': 'http://localhost/dummy/blocklist/',
          # Do not automatically fill sign-in forms with known usernames and passwords
          'signon.autofillForms': false,
          # Disable password capture, so that tests that include forms are not
          # influenced by the presence of the persistent doorhanger notification
          'signon.rememberSignons': false,
          # Disable first-run welcome page
          'startup.homepage_welcome_url': 'about:blank',
          # Disable first-run welcome page
          'startup.homepage_welcome_url.additional': '',
          # Disable browser animations (tabs, fullscreen, sliding alerts)
          'toolkit.cosmeticAnimations.enabled': false,
          # Prevent starting into safe mode after application crashes
          'toolkit.startup.max_resumed_crashes': -1,
        }
        prefs = default_prefs.map { |key, value| "user_pref(\"#{key}\", #{JSON.dump(value)});" }
        # apparently firefox will read user.js and generate prefs.js from it
        File.binwrite(profile + '/user.js', prefs.join("\n"))
        profile
      end
    end
  end
end
