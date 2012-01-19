#############################################################
# DEBUG - only included in debug mode
#

class Exception
  def backtrace
    `debug_get_backtrace(this)`
  end
end
