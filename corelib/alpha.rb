# load path getters
$LOAD_PATH = $: = `LOADER_PATHS`

# regexp matches
$~ = nil

class String
  def to_s
    `self.toString()`
  end
end
