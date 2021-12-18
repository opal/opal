require 'tmpdir'

module Opal
  module CliRunners
    class BrowserRunner
      def self.call(data)
        runner = new(data)
        runner.run
      end

      def self.describe
        name.split("::").last
      end

      def initialize(data)
        builder = data[:builder]
        options = data[:options]
        argv    = data[:argv]

        if argv && argv.any?
          warn "warning: ARGV is not supported by the #{self.class.describe} runner #{argv.inspect}"
        end

        @output = options.fetch(:output, $stdout)
        @builder = builder
      end

      def run
        raise NotImplementedError
      end

      attr_reader :output, :exit_status, :builder

      private

      def prepare_files_in(dir)
        js = builder.to_s
        map = builder.source_map.to_json
        stack = File.read("#{__dir__}/source-map-support-browser.js")

        # Chrome can't handle huge data passed to `addScriptToEvaluateOnLoad`
        # https://groups.google.com/a/chromium.org/forum/#!topic/chromium-discuss/U5qyeX_ydBo
        # The only way is to create temporary files and pass them to chrome.
        File.write("#{dir}/index.js", js)
        File.write("#{dir}/source-map-support.js", stack)
        # Let's serve it a 1x1 transparent GIF, so that Firefox won't complain:
        File.binwrite("#{dir}/favicon.ico", "GIF89a\x01\0\x01\0\x80\0\0\xFF\xFF\xFF\xFF\xFF" \
                                            "\xFF!\xF9\x04\x01\0\0\x01\0,\0\0\0\0\x01\0\x01" \
                                            "\0\0\x02\x02L\x01\0;")
        File.write("#{dir}/index.html", <<~HTML)
          <html><head>
            <meta charset='utf-8'>
            <script src='./source-map-support.js'></script>
            <script>
            window.OpalHeadless = true;
            sourceMapSupport.install({
              retrieveSourceMap: function(path) {
                return path.endsWith('/index.js') ? {
                  url: './index.map', map: #{map.to_json}
                } : null;
              }
            });
            </script>
          </head><body>
            <script src='./index.js'></script>
          </body></html>
        HTML
      end

      def mktmpdir(&block)
        Dir.mktmpdir("#{self.class.describe.downcase}-opal-", &block)
      end
    end
  end
end