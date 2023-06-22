Benchmark.ips do |x|
  %x{
    function old_way(keys, smap) {
      var hash = new Opal.Hash();
  
      hash.$$smap = smap;
      hash.$$map  = Object.create(null);
      hash.$$keys = keys;
  
      return hash;
    };

    function new_way(keys, smap) {
      var hash = new Opal.Hash();
  
      hash.$$smap = smap;
      hash.$$map  = {};
      hash.$$keys = keys;
  
      return hash;
    };
   }

  values = [123,243,35,"sd",false,nil,123413234,120412,0,1234.1234,0.34,false,false,true,"sadfasf","","0",13,123,nil,Object.new,[]]

  oh = `old_way([], {})`
  oh[:prop] = 1
  nh = `new_way([], {})`
  nh[:prop] = 1

  x.time = 32

  x.report('old_way') { oh[:prop] }
  x.report('new_way') { nh[:prop] }

  x.compare!
end
