Benchmark.ips do |x|
  %x{
    var falsy_vals = [undefined, null, nil, false];

    // Old version truthy logic
    var truthy1 = function(x) { return x !== nil && x != null && (!x.$$is_boolean || x == true); }
    // New version truthy logic
    var truthy2 = function(val) { return undefined !== val && null !== val && false !== val && nil !== val && (!(val instanceof Boolean) || true === val.valueOf()); }
    // Alternative new version truthy logic
    var truthy2a = function(val) { return undefined !== val && null !== val && false !== val && nil !== val && !(val instanceof Boolean && false === val.valueOf()); }
    // Alternative new version truthy logic that unsupports boxed booleans
    var truthy3 = function(val) { return undefined !== val && null !== val && false !== val && nil !== val; }
  }

  values = [123,243,35,"sd",false,nil,123413234,120412,0,1234.1234,0.34,false,false,true,"sadfasf","","0",13,123,nil,Object.new,[]]

  x.time = 32

  x.report('truthy1') { values.map(&`truthy1`) }
  x.report('truthy2') { values.map(&`truthy2`) }
  x.report('truthy2a') { values.map(&`truthy2a`) }
  x.report('truthy3') { values.map(&`truthy3`) }

  x.compare!
end
