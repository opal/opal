Benchmark.ips do |x|
  obj = Object.new
  x.report("numeric statement") do
    case 1
    when 4 then 4
    when 3 then 3
    when 2 then 2
    when 1 then 1
    end
    nil
  end
  x.report("statement") do
    case 1
    when 4 then 4
    when 3 then 3
    when 2 then 2
    when obj then :obj
    when 1 then 1
    end
    nil
  end
  x.report("expression") do
    case 1
    when 4 then 4
    when 3 then 3
    when 2 then 2
    when obj then :obj
    when 1 then 1
    end
  end

  x.compare!
end
