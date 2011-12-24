/* This file is part of OWL JavaScript Utilities.

OWL JavaScript Utilities is free software: you can redistribute it and/or 
modify it under the terms of the GNU Lesser General Public License
as published by the Free Software Foundation, either version 3 of
the License, or (at your option) any later version.

OWL JavaScript Utilities is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public 
License along with OWL JavaScript Utilities.  If not, see 
<http://www.gnu.org/licenses/>.
*/

opal.clone = function(target) {
  if (typeof(target) === 'object') {
    var klass           = function() {};
        klass.prototype = target

    return new klass();
  }
  else {
    return target;
  }
}

opal.copy = function(target) {
  if (typeof(target) !== 'object') {
    return target; // non-object have value semantics, so target is already a copy.
  }

  var value = target.valueOf(),
      result;

  if (target != value) {
    // the object is a standard object wrapper for a native type, say String.
    // we can make a copy by instantiating a new object around the value.
    return new target.constructor(value);
  }

  // ok, we have a normal object. If possible, we'll clone the original's prototype
  // (not the original) to get an empty object with the same prototype chain as
  // the original.  If just copy the instance properties.  Otherwise, we have to
  // copy the whole thing, property-by-property.
  if (target instanceof target.constructor && target.constructor !== Object ) {
    result = opal.clone(target.constructor.prototype);

    // give the copy all the instance properties of target.  It has the same
    // prototype as target, so inherited properties are already there.
    for (var property in target) {
      if (target.hasOwnProperty(property)) {
        result[property] = target[property];
      }
    }
  }
  else {
    result = {}

    for (var property in target) {
      result[property] = target[property];
    }
  }

  return result;
}

opal.deep_copy = function(target) {
  if (typeof(target) !== 'object') {
    return target; // non-object have value semantics, so target is already a copy.
  }

  var value = target.valueOf(),
      result;

  if (target != value) {
    // the object is a standard object wrapper for a native type, say String.
    // we can make a copy by instantiating a new object around the value.
    return new target.constructor(value);
  }

  // ok, we have a normal object. If possible, we'll clone the original's prototype
  // (not the original) to get an empty object with the same prototype chain as
  // the original.  If just copy the instance properties.  Otherwise, we have to
  // copy the whole thing, property-by-property.
  if (target instanceof target.constructor && target.constructor !== Object ) {
    result = opal.clone(target.constructor.prototype);

    // give the copy all the instance properties of target.  It has the same
    // prototype as target, so inherited properties are already there.
    for (var property in target) {
      if (target.hasOwnProperty(property)) {
        result[property] = opal.deep_copy(target[property]);
      }
    }
  }
  else {
    result = {}

    for (var property in target) {
      result[property] = opal.deep_copy(target[property]);
    }
  }

  return result;
}
