
def foo
  bar
end

def bar
  baz_doesnt_exist
end

[1, 2, 3, 4].each do |num|
  foo
end
