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

class << $stdout
  # private variable used to buffer stdout until flush
  `var stdout_buffer = [];`

  def write(str)
    `stdout_buffer.push(str);`
    nil
  end

  def flush
    `console.log(stdout_buffer.join(''));`
    `stdout_buffer = [];`
    nil
  end
end
