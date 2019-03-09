# SOURCE: https://raw.githubusercontent.com/RReverser/stack-displayname/13732cedc506200ee8465edcbfce00a9e914853c/displayName.js

# Copyright 2014 Ingvar Stepanyan
#
# Copyright 2006-2011, the V8 project authors. All rights reserved.
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above
#       copyright notice, this list of conditions and the following
#       disclaimer in the documentation and/or other materials provided
#       with the distribution.
#     * Neither the name of Google Inc. nor the names of its
#       contributors may be used to endorse or promote products derived
#       from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

%x{
  (function () {

  if (!Error.captureStackTrace) {
    return;
  }

  var ObjectToString = Object.prototype.toString;

  var NODE = ObjectToString.call(process) === "[object process]";

  // https://github.com/v8/v8/blob/cab94bbe3d532d85705950ed049a294050fcb4c9/src/messages.js#L1112-L1124 [converted to JS]
  function GetTypeName(receiver, requireConstructor) {
    if (receiver == null) return null;
    var constructor = receiver.constructor;
    if (!constructor) {
      return requireConstructor ? null : ObjectToString.call(receiver);
    }
    var constructorName = constructor.name;
    if (!constructorName) {
      return requireConstructor ? null : ObjectToString.call(receiver);
    }
    return constructorName;
  }

  // https://github.com/v8/v8/blob/cab94bbe3d532d85705950ed049a294050fcb4c9/src/messages.js#L917-L981 [converted & modified]
  function CallSiteToString() {
    var fileName;
    var fileLocation = "";
    if (this.isNative()) {
      fileLocation = "native";
    } else {
      fileName = this.getScriptNameOrSourceURL();
      if (!fileName && this.isEval()) {
        fileLocation = this.getEvalOrigin();
        fileLocation += ", "; // Expecting source position to follow.
      }

      if (fileName) {
        fileLocation += fileName;
      } else {
        // Source code does not originate from a file and is not native, but we
        // can still get the source position inside the source string, e.g. in
        // an eval string.
        fileLocation += "<anonymous>";
      }
      var lineNumber = this.getLineNumber();
      if (lineNumber !== null) {
        fileLocation += ":" + lineNumber;
        var columnNumber = this.getColumnNumber();
        if (columnNumber) {
          fileLocation += ":" + columnNumber;
        }
      }
    }

    var line = "";
    var func = this.getFunction();
    if (func) var customName = func.displayName;
    if (NODE && customName) {
      if (customName && func.$$owner) {
        var customNameOwner;
        customNameOwner = (func.$$owner.displayName || func.$$owner.$$name);
        customName = (func.$$owner.singleton_of ? '.' : '#') + customName;
      }
      customName = customNameOwner + customName;
    }
    var functionName = customName || this.getFunctionName();
    var addSuffix = true;
    var isConstructor = this.isConstructor();
    var isMethodCall = !(this.isToplevel() || isConstructor);
    if (isMethodCall) {
      var typeName = GetTypeName(this.receiver, true);
      var methodName = this.getMethodName();
      if (functionName) {
        if (!customName && typeName && functionName.indexOf(typeName) !== 0) {
          line += typeName + ".";
        }
        line += functionName;
        if (methodName && methodName !== functionName) {//} && functionName.indexOf("." + methodName) !== functionName.length - methodName.length - 1) {
          line += " [as " + methodName + "]";
        }
      } else {
        line += typeName + "." + (methodName || "<anonymous>");
      }
    } else if (isConstructor) {
      line += "new " + (functionName || "<anonymous>");
    } else if (functionName) {
      if (func.$$s) {
        if (func.$$s.displayName || func.$$s.$$name) {
          line += 'block in ' + (func.$$s.displayName || func.$$s.$$name) + ' [as ' + functionName + ']';
        } else if (func.$$s.$$class && func.$$s.$$class.$$name) {
          line += 'block in #<' + func.$$s.$$class.$$name + ' $$id: ' + Opal.id(func.$$s) + '> [as ' + functionName + ']';
        } else {
          line += functionName;
        }
      } else {
        line += functionName;
      }
    } else {
      line += fileLocation;
      addSuffix = false;
    }
    if (addSuffix) {
      line += " (" + fileLocation + ")";
    }
    return line;
  }

  var ErrorToString = Error.prototype.toString;

  // https://github.com/v8/v8/blob/cab94bbe3d532d85705950ed049a294050fcb4c9/src/messages.js#L1042-L1052 [converted]
  function FormatErrorString(error) {
    try {
      return ErrorToString.call(error);
    } catch (e) {
      try {
        return "<error: " + e + ">";
      } catch (ee) {
        return "<error>";
      }
    }
  }

  // https://github.com/v8/v8/blob/cab94bbe3d532d85705950ed049a294050fcb4c9/src/messages.js#L1091-L1108 [logic duplicated]
  Error.prepareStackTrace = function (error, frames) {
    var lines = [];
    lines.push(FormatErrorString(error));
    for (var i = 0; i < frames.length; i++) {
      var frame = frames[i];
      var line;
      try {
        line = CallSiteToString.call(frame);
      } catch (e) {
        try {
          line = "<error: " + e + ">";
        } catch (ee) {
          // Any code that reaches this point is seriously nasty!
          line = "<error>";
        }
      }
      lines.push("    at " + line);
    }
    return lines.join("\n");
  };

  })();
}
