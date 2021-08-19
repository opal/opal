klasses = [
  Array,
  Class,
  # Complex,
  # Dir,
  Enumerable,
  Enumerator,
  Exception,
  Hash,
  # Kernel,
  Math,
  Method,
  Module,
  Object,
  Proc,
  Range,
  Rational,
  Regexp,
  Struct,
  String,
  Time
]

%x{
  function getOptimizationStatus(fn) {
    var optstatus = %GetOptimizationStatus(fn);

    return (optstatus & (1 << 6)) ? "[INTERPRETED]" : "[COMPILED]";
  }
  
  function triggerOptAndGetStatus(fn) {
    // using try/catch to avoid having to call functions properly
    try {
      // Fill type-info
      fn();
      // 2 calls are needed to go from uninitialized -> pre-monomorphic -> monomorphic
      fn();
    }
    catch (e) {}
    %OptimizeFunctionOnNextCall(fn);
    try {
      fn();
    }
    catch (e) {}
    return getOptimizationStatus(fn);
  }
}

optimization_status = Hash[klasses.map do |klass|
  methods = klass.instance_methods
  methods -= Object.instance_methods unless klass == Object
  methods -= [:product, :exit, :exit!, :at_exit]
  opt_status = Hash[methods.map do |method|
    method_func = `#{klass.instance_method(method)}.method`
    [method, `triggerOptAndGetStatus(#{method_func})`]
  end]
  by_status_grouped = opt_status.group_by {|method, status| status }
  as_hash = Hash[by_status_grouped.map do |status, stuff|
    list = stuff.map {|val| val[0]}
    [status, list]
  end]
  [klass, as_hash]
end]

puts '----Report----'
optimization_status.sort_by {|klass,_| klass.name}.each do |klass, statuses|
  puts "---------------"
  puts "Class #{klass}:"
  puts "---------------"
  statuses.sort_by {|stat,_| stat }.each do |status, methods|
    methods.sort.each do |m|
      puts "  #{status} #{m}"
    end
  end
end

puts 'done!'