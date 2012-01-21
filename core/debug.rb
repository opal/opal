#############################################################
# DEBUG - only included in debug mode
#

class Exception
  def backtrace
    `$opal.backtrace(this)`
  end
end
