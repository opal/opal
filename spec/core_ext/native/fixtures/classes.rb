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
      },

      array: [1, 2, 3, 4],

      child_object: {
        grand_child: 100
      }
    };
  }

  OBJ = Native.new(`obj`)
end
