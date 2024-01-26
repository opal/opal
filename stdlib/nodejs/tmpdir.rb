class Dir
  def self.mktmpdir(prefix_suffix = nil, *_rest, **_options)
    if `prefix_suffix.$$is_array`
      prefix = prefix_suffix.join('')
    elsif `prefix_suffix.$$is_string`
      prefix = prefix_suffix
    else
      prefix = 'd'
    end

    path = `#@__fs__.mkdtempSync(prefix)`
    if block_given?
      res = yield path
      `#@__fs__.rmdirSync(path)`
      return res
    end
    path
  end

  def self.tmpdir
    `#@__os__.tmpdir()`
  end
end
