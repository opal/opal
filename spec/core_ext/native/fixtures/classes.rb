module NativeSpecs
  %x{
    var obj = {
      property: 42,

      simple: function() {
        return 'foo';
      },

      context_check: function() {
        return this === obj;
      },

      check_args: function(a, b, c) {
        return [a, b, c];
      }
    };
  }

  OBJ = Native.new(`obj`)
end
