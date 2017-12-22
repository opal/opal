module PackUnpack
  %x{
    var directives = [
      // Integer
      'C', // supported
      'S', // supported
      'L', // supported
      'Q', // supported
      'J',

      'c', // supported
      's', // supported
      'l', // supported
      'q', // supported
      'j',

      'n', // supported
      'N', // supported
      'v', // supported
      'V', // supported

      'U', // supported
      'w', // supported

      // Float
      'D',
      'd',
      'F',
      'f',
      'E',
      'e',
      'G',
      'g',

      // String
      'A', // supported
      'a', // supported
      'Z', // supported
      'B', // supported
      'b', // supported
      'H', // supported
      'h', // supported
      'u', // supported
      'M',
      'm', // supported

      'P',
      'p',

      // Misc
      '@',
      'X',
      'x',
    ];

    var modifiers = [
      '!', // ignored
      '_', // ignored
      '>', // big endian
      '<'  // little endian
    ];

    self.eachDirectiveAndCount = function(format, callback) {
      var currentDirective,
          currentCount,
          currentModifiers,
          countSpecified;

      function reset() {
        currentDirective = null;
        currentCount = 0;
        currentModifiers = [];
        countSpecified = false;
      }

      reset();

      function yieldAndReset() {
        if (currentDirective == null) {
          reset();
          return;
        }

        var directiveSupportsModifiers = /[sSiIlLqQjJ]/.test(currentDirective);

        if (!directiveSupportsModifiers && currentModifiers.length > 0) {
          #{raise ArgumentError, "'#{`currentModifiers[0]`}' allowed only after types sSiIlLqQjJ"}
        }

        if (currentModifiers.indexOf('<') !== -1 && currentModifiers.indexOf('>') !== -1) {
          #{raise RangeError, "Can't use both '<' and '>'"}
        }

        if (!countSpecified) {
          currentCount = 1;
        }

        if (currentModifiers.indexOf('>') !== -1) {
          currentDirective = currentDirective + '>';
        }

        callback(currentDirective, currentCount);

        reset();
      }

      for (var i = 0; i < format.length; i++) {
        var currentChar = format[i];

        if (directives.indexOf(currentChar) !== -1) {
          // Directive char always resets current state
          yieldAndReset();
          currentDirective = currentChar;
        } else if (currentDirective) {
          if (/\d/.test(currentChar)) {
            // Count can be represented as a sequence of digits
            currentCount = currentCount * 10 + parseInt(currentChar, 10);
            countSpecified = true;
          } else if (currentChar === '*' && countSpecified === false) {
            // Count can be represented by a star character
            currentCount = Infinity;
            countSpecified = true;
          } else if (modifiers.indexOf(currentChar) !== -1 && countSpecified === false) {
            // Directives can be specified only after directive and before count
            currentModifiers.push(currentChar);
          } else {
            yieldAndReset();
          }
        }
      }

      yieldAndReset();
    }
  }
end
