#  def to_a
#    %x{
#      var n = #{@native}, result;

 #     if (n.length) {
#        result = [];

#        for (var i = 0, len = n.length; i < len; i++) {
#          result.push(#{ Native.new `n[i]` });
#        }
#      }
#      else {
#        result = [n];
#      }

#      return result;
#    }
#  end

$global = `Opal.global`
$window = $global
$document = $window.document

