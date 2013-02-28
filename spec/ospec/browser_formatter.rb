module OSpec
  class BrowserFormatter
    CSS = <<-CSS

      body {
        font-size: 14px;
        font-family: Helvetica Neue, Helvetica, Arial, sans-serif;
      }

      pre {
        font-family: "Bitstream Vera Sans Mono", Monaco, "Lucida Console", monospace;
        font-size: 12px;
        color: #444444;
        white-space: pre;
        padding: 3px 0px 3px 12px;
        margin: 0px 0px 8px;

        background: #FAFAFA;
        -webkit-box-shadow: rgba(0,0,0,0.07) 0 1px 2px inset;
        -webkit-border-radius: 3px;
        -moz-border-radius: 3px;
        border-radius: 3px;
        border: 1px solid #DDDDDD;
      }

      ul.example_groups {
        list-style-type: none;
      }

      li.group.passed .group_description {
        color: #597800;
        font-weight: bold;
      }

      li.group.failed .group_description {
        color: #FF000E;
        font-weight: bold;
      }

      li.example.passed {
        color: #597800;
      }

      li.example.failed {
        color: #FF000E;
      }

      .examples {
        list-style-type: none;
      }
    CSS

    def initialize
      @examples        = []
      @failed_examples = []
    end

    def start
      %x{
        if (!document || !document.body) {
          #{ raise "Not running in browser." };
        }

        var summary_element = document.createElement('p');
        summary_element.className = 'summary';
        summary_element.innerHTML = "Running...";

        var groups_element = document.createElement('ul');
        groups_element.className = 'example_groups';

        var target = document.getElementById('opal-spec-output');

        if (!target) {
          target = document.body;
        }

        target.appendChild(summary_element);
        target.appendChild(groups_element);

        var styles = document.createElement('style');
        styles.type = 'text/css';

        if (styles.styleSheet) {
          styles.styleSheet.cssText = __scope.CSS;
        }
        else {
          styles.appendChild(document.createTextNode(__scope.CSS));
        }

        document.getElementsByTagName('head')[0].appendChild(styles);
      }

      @start_time = Time.now.to_f
      @groups_element = `groups_element`
      @summary_element = `summary_element`
    end

    def finish
      time = Time.now.to_f - @start_time
      text = "\n#{example_count} examples, #{@failed_examples.size} failures (time taken: #{time})"
      `#{@summary_element}.innerHTML = text`
    end

    def example_group_started group
      @example_group = group
      @example_group_failed = false

      %x{
        var group_element = document.createElement('li');

        var description = document.createElement('span');
        description.className = 'group_description';
        description.innerHTML = #{group.description.to_s};
        group_element.appendChild(description);

        var example_list = document.createElement('ul');
        example_list.className = 'examples';
        group_element.appendChild(example_list);

        #@groups_element.appendChild(group_element);
      }

      @group_element = `group_element`
      @example_list  = `example_list`
    end

    def example_group_finished group
      if @example_group_failed
        `#@group_element.className = 'group failed';`
      else
        `#@group_element.className = 'group passed';`
      end
    end

    def example_started example
      @examples << example
      @example = example
    end

    def example_failed example
      @failed_examples << example
      @example_group_failed = true

      exception = example.exception

      case exception
      when OSpec::ExpectationNotMetError
        output  = exception.message
      else
        output  = "#{exception.class.name}: #{exception.message}\n"
        output += "    #{exception.backtrace.join "\n    "}\n"
      end

      %x{
        var wrapper = document.createElement('li');
        wrapper.className = 'example failed';

        var description = document.createElement('span');
        description.className = 'example_description';
        description.innerHTML = #{example.description};

        var exception = document.createElement('pre');
        exception.className = 'exception';
        exception.innerHTML = output;

        wrapper.appendChild(description);
        wrapper.appendChild(exception);

        #@example_list.appendChild(wrapper);
        #@example_list.style.display = 'list-item';
      }
    end

    def example_passed example
      %x{
        var wrapper = document.createElement('li');
        wrapper.className = 'example passed';

        var description = document.createElement('span');
        description.className = 'example_description';
        description.innerHTML = #{example.description};

        wrapper.appendChild(description);
        #@example_list.appendChild(wrapper);
      }
    end

    def example_count
      @examples.size
    end
  end
end
