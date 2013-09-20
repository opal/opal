opal_filter "Array#+" do
  fails "Array#+ tries to convert the passed argument to an Array using #to_ary"
end
