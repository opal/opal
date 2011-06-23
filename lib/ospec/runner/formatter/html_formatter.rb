module Spec
  module Runner
    module Formatter
      class HtmlFormatter

        attr_reader :example_group, :example_group_number

        def initialize(options)
          @options = options
          @example_group_number = 0
          @example_number = 0
          @header_red = nil

          setup_page_dom
        end

        ##
        # Get the DOM ready for output
        #
        def setup_page_dom
          content = [
            "<style>#{css_content}</style>",
            '<div class="rspec-report">',
              '<div id="rspec-header">',
                '<div id="label">',
                  '<h1>Rspec Code Examples</h1>',
                '</div>',

                '<div id="summary">',
                  '<p id="totals">0</p>',
                  '<p id="duration">0</p>',
                '</div>',
              '</div>',
              '<div id="results">',
              '</div>',
            '</div>'
          ].join ''
          `var wrapper = document.createElement('div');
          wrapper.id = "rspec-wrapper";
          wrapper.innerHTML = content;
          document.getElementsByTagName('body')[0].appendChild(wrapper);`
          `self.$results = document.getElementById('results');`
         nil 
        end

        def css_content
          'body{ margin:0px; padding:0px; background:white; font-size:80%}#rspec-header{ background:#65C400;color:#fff;height:4em}.rspec-report h1{ margin:0px 10px 0px 10px; padding:10px; font-family:"Lucida Grande",Helvetica,sans-serif; font-size:1.8em; position:absolute}#summary{ margin:0;padding:5px 10px; font-family:"Lucida Grande",Helvetica,sans-serif; text-align:right; top:0px; right:0px; float:right}#summary p{ margin:0 0 0 2px}#summary #totals{ font-size:1.2em}#results{}.example_group{ margin:0 10px 5px; background:#fff}dl{ margin:0;padding:0 0 5px; font:normal 11px "Lucida Grande",Helvetica,sans-serif}dt{ padding:3px; background:#65C400; color:#fff; font-weight:bold}dd{ margin:5px 0 5px 5px; padding:3px 3px 3px 18px}dd.spec.passed{ border-left:5px solid #65C400; border-bottom:1px solid #65C400; background:#DBFFB4;color:#3D7700}dd.spec.failed{ border-left:5px solid #C20000; border-bottom:1px solid #C20000; color:#C20000;background:#FFFBD3}dd.spec.not_implemented{ border-left:5px solid #FAF834; border-bottom:1px solid #FAF834; background:#FCFB98;color:#131313}dd.spec.pending_fixed{ border-left:5px solid #0000C2; border-bottom:1px solid #0000C2; color:#0000C2;background:#D3FBFF}.backtrace{ color:#000; font-size:12px}a{ color:#BE5C00}.ruby{ font-size:12px; font-family:monospace; color:white; background-color:black; padding:0.1em 0 0.2em 0}.ruby .keyword{color:#F60}.ruby .constant{color:#399}.ruby .attribute{color:white}.ruby .global{color:white}.ruby .module{color:white}.ruby .class{color:white}.ruby .string{color:#6F0}.ruby .ident{color:white}.ruby .method{color:#FC0}.ruby .number{color:white}.ruby .char{color:white}.ruby .comment{color:#93C}.ruby .symbol{color:white}.ruby .regex{color:#44B4CC}.ruby .punct{color:white}.ruby .escape{color:white}.ruby .interp{color:white}.ruby .expr{color:white}.ruby .offending{background-color:gray}.ruby .linenum{ width:75px; padding:0.1em 1em 0.2em 0; color:#000; background-color:#FFFBD3}'
        end


        def start(number_of_examples)

        end

        def end
          @end_time = Time.now
        end

        def example_group_started(example_group)
          @example_group = example_group
          @example_group_red = false
          @example_group_number += 1
          
          # @example_group_div = results_output.div :class_name => "example_group"
          # @example_group_dl = @example_group_div.dl
          # @example_group_dt = @example_group_dl.dt :content  => example_group.description, :id       => "example_group_#{example_group_number}"

          `var div = self.$example_div = document.createElement('div');
          div.className = 'example_group';

          var dl = self.$example_dl = document.createElement('dl');
          div.appendChild(dl);

          var dt = self.$example_dt = document.createElement('dt');
          dt.innerHTML = #{example_group.description};
          dt.id = "element_group_" + #{@element_group_number.to_s};
          dl.appendChild(dt);

          self.$results.appendChild(div);`

        end
        
        def example_started(example)

        end
        
        def example_failed(example, counter, failure)
          @header_red = true
          @example_group_red = true

          `var dd = document.createElement('dd');
          dd.className = "spec failed";

          var span = document.createElement('span');
          span.innerHTML = #{example.description};
          span.className = "failed_spec_name";
          dd.appendChild(span);

          self.$example_dl.appendChild(dd);

          var failure_div = document.createElement('div');
          failure_div.className = "failure";

          var msg = document.createElement('div');
          msg.className = "message";

          var pre = document.createElement('pre');
          pre.innerHTML = #{failure.exception.message};
          msg.appendChild(pre);

          failure_div.appendChild(msg);
          dd.appendChild(failure_div);`

          nil
        end

        def example_passed(example)
          `var dl = self.$example_dl;

          var dd = document.createElement('dd');
          dd.className = "spec passed";

          var span = document.createElement('span');
          dd.appendChild(span);
          span.innerHTML = #{example.description.to_s};
          span.className = "passed_spec_name";

          dl.appendChild(dd);`
          nil
        end
        
        def example_pending(example, message)
          # @example_group_dl.dd(:class_name => "spec not_implemented").span(:content => "#{example.description} (PENDING: #{message})", :class_name => "not_implemented_spec_name")
        end
      end
    end
  end
end

