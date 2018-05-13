class A
  def m
  end
end

a = A.new
def a.mm
end
p a.methods(false)

`debugger`
13
