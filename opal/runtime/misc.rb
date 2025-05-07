# backtick_javascript: true
# use_strict: true
# opal_runtime_mode: true
# helpers: return_val, Object

module ::Opal
  # Create a new range instance with first and last values, and whether the
  # range excludes the last value.
  def self.range(first, last, exc)
    %x{
      var range         = new Opal.Range();
          range.begin   = first;
          range.end     = last;
          range.excl    = exc;

      return range;
    }
  end

  # top is the main object. It is a `self` in a top level of a Ruby program
  %x{
    Opal.top.$to_s = Opal.top.$inspect = $return_val('main');
    Opal.top.$define_method = top_define_method;

    // Foward calls to define_method on the top object to Object
    function top_define_method() {
      var block = top_define_method.$$p;
      top_define_method.$$p = null;
      return Opal.send($Object, 'define_method', arguments, block)
    };
  }

  # Exit handler, see #create_builder in lib/opal/cli.rb
  def self.run_end_procs_and_exit(system_exit)
    status = system_exit.status

    $__at_exit__ ||= []

    until $__at_exit__.empty?
      block = $__at_exit__.pop
      begin
        block.call
      rescue ::SystemExit => e
        status = e.status
      rescue => e
        # ignore
      end
    end

    `Opal.platform.exit(status)`
  end
end

::Opal
