key = "foo"
def key.reverse
  "bar"
end
p key.methods(false)
h = {}
h.store(key, 0)
p h.keys[0].reverse
p "oof"
