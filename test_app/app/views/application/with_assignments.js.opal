# Fix to native which is broken on some basic types
class Hash
  def to_native
    %x{
      var result = {}, map = #{self}.map, bucket, value;

      for (var assoc in map) {
        bucket = map[assoc];
        value  = bucket[1];

        if (value.$to_native) {
          result[assoc] = #{ `value`.to_native };
        }
        else {
          result[assoc] = value;
        }
      }

      return result;
    }
  end
end

return {
  number_var: @number_var,
  string_var: @string_var,
  array_var:  @array_var,
  hash_var:   @hash_var,
  object_var: @object_var,
  local_var:  local_var
}.to_native
