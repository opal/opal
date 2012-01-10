# ...........................................................
# DEBUG - only included in debug mode
#

class Exception
  def backtrace
    `get_debug_backtrace(this)`
  end
end
