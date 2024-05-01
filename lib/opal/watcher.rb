class Opal::Watcher
  attr_reader :paths

  def initialize(paths, &block)
    @paths = paths.is_a?(Array) ? paths : [paths]
    @mtimes = {}
    @block = block
    # fill mtimes
    @paths.each do |path|
      detect_modifications({ modified: [], added: [], removed: [] }, path)
    end
  end

  def poll_updates
    updates = { modified: [], added: [], removed: [] }
    @paths.each do |path|
      detect_modifications(updates, path)
    end
    updates
  end

  def detect_modifications(updates, path)
    stat = File::Stat.new(path)
    current_mtime_h = if stat.file?
                        { mtime: stat.mtime.to_i, type: :file }
                      elsif stat.directory?
                        { mtime: stat.mtime.to_i, type: :dir, entries: Dir.entries(path).reject { |e| '.' == e || '..' == e }.sort.map { |e| File.join(path, e) } }
                      end
    previous_mtime_h = @mtimes.fetch(path, { mtime: 0, type: :na, entries: nil })
    if current_mtime_h[:mtime] != previous_mtime_h[:mtime] || current_mtime_h[:type] != previous_mtime_h[:type]
      @mtimes[path] = current_mtime_h
      if previous_mtime_h[:mtime] == 0 || previous_mtime_h[:type] == :na
        updates[:added] << path
      else
        updates[:modified] << path
      end
    end
    if stat.directory?
      found_entries = []
      Dir.each_child(path) do |entry|
        entry_path = File.join(path, entry)
        found_entries << entry_path
        detect_modifications(updates, entry_path)
      end
      found_entries.sort!
      if previous_mtime_h[:type] == :dir
        updates[:removed].concat(previous_mtime_h[:entries] - found_entries)
      end
    end
  rescue Errno::ENOENT
    updates[:removed] << path
  end

  def poll_loop
    loop do
      updates = poll_updates
      if updates[:modified].any? || updates[:added].any? || updates[:removed].any?
        @block.call(updates[:modified], updates[:added], updates[:removed])
      end
      sleep 0.25
    end
  end

  if RUBY_ENGINE != 'opal'
    def start
      return if @thread
      @thread = Thread.new do
        loop
      end
      @thread.run
      nil
    end

    def stop
      @thread.kill
    end
  end
end
