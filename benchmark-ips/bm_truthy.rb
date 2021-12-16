Benchmark.ips do |x|
  %x{
    // Old version truthy logic
    var old_version   = function(x) { return x !== nil && x != null && (!x.$$is_boolean || x == true); }

    // New version truthy logic
    var new_version_1 = function(val) { return undefined !== val && null !== val && false !== val && nil !== val && (!(val instanceof Boolean) || true === val.valueOf()); }

    // Alternative new version truthy logic
    var new_version_2 = function(val) { return undefined !== val && null !== val && false !== val && nil !== val && !(val instanceof Boolean && false === val.valueOf()); }

    // Alternative new version, nil&false first
    var new_version_3 = function(val) { return false !== val && nil !== val && undefined !== val && null !== val && !(val instanceof Boolean && false === val.valueOf()); }

    // Alternative new version truthy logic that unsupports boxed booleans
    var new_unboxed   = function(val) { return undefined !== val && null !== val && false !== val && nil !== val; }
  }

  values = [123,243,35,"sd",false,nil,123413234,120412,0,1234.1234,0.34,false,false,true,"sadfasf","","0",13,123,nil,Object.new,[]]

  x.time = 32

  x.report('old_version') { values.map(&`old_version`) }
  x.report('new_version_1') { values.map(&`new_version_1`) }
  x.report('new_version_2') { values.map(&`new_version_2`) }
  x.report('new_version_3') { values.map(&`new_version_3`) }
  x.report('new_unboxed') { values.map(&`new_unboxed`) }

  x.compare!
end
