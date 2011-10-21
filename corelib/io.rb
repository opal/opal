class IO

  def puts(*args)
    return flush if args.empty?
    args.each do |a|
      write a.to_s
      flush
    end
  end

  def print(*args)
    args.each { |a| write a.to_s }
    nil
  end

  def flush
    self
  end
end

