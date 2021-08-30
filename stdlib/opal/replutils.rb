require 'pp'

module REPLUtils
  module_function

  def ls(object)
    methods = imethods = object.methods
    ancestors = object.class.ancestors
    constants = []
    ivs = object.instance_variables
    cvs = []

    if [Class, Module].include? object.class
      imethods = object.instance_methods
      ancestors = object.ancestors
      constants = object.constants
      cvs = object.class_variables
    end

    out = ''
    out = "class variables: #{cvs.sort.join('  ')}\n" + out unless cvs.empty?
    out = "instance variables: #{ivs.sort.join('  ')}\n" + out unless ivs.empty?
    ancestors.each do |a|
      im = a.instance_methods(false)
      meths = (im & imethods)
      methods -= meths
      imethods -= meths
      next if meths.empty? || [Object, BasicObject, Kernel, PP::ObjectMixin].include?(a)
      out = "#{a.name}#methods: #{meths.sort.join('  ')}\n" + out
    end
    methods &= object.methods(false)
    out = "self.methods: #{methods.sort.join('  ')}\n" + out unless methods.empty?
    out = "constants: #{constants.sort.join('  ')}\n" + out unless constants.empty?
    out
  end

  def eval_and_print(func, mode)
    %x{
      var $_result = #{func}();

      if (typeof $_result === 'null') {
        return "=> null";
      }
      else if (typeof $_result === 'undefined') {
        return "=> undefined";
      }
      else if (typeof $_result.$$class === 'undefined') {
        try {
          return "=> " + $_result.toString() + " => " + JSON.stringify($_result, null, 2);
        }
        catch(e) {
          return "=> " + $_result.toString();
        }
      }
      else {
        if (mode == 'ls') {
          return #{ls(`$_result`)};
        }
        else {
          var pretty = #{`$_result`.pretty_inspect};
          // Is it multiline? If yes, add a linebreak
          if (pretty.match(/\n.*?\n/)) pretty = "\n" + pretty;
          return "=> " + pretty;
        }
      }
    }
    `ret`
  rescue Exception => e # rubocop:disable Lint/RescueException
    e.full_message(highlight: true)
  end
end
