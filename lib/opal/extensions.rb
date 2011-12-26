class Array
  def to_syms
    map &:to_sym
  end
end
