module M1; def m1; end end
module M2; def m2; end; end

class C1;      include M1; def m3; end; end
class C2 < C1; include M2; def m4; end; end

# if RUBY_ENGINE == 'opal'
  print = ->(data) { `console.log(data)` }
  names_of_mods = ->(mods) { mods.map { |mod| `mod.$$name` } }

  print.call(names_of_mods.call(`Opal.C1.$ancestors()`));
  print.call(names_of_mods.call(`Opal.C2.$ancestors()`));

  print.call(names_of_mods.call(`Opal.C1.$$included_modules`));
  print.call(names_of_mods.call(`Opal.C2.$$included_modules`));
# else
#   p C1.ancestors
#   p C2.ancestors

#   p C1.included_modules
#   p C2.included_modules
# end


# if RUBY_ENGINE == 'opal'
#   p `Opal.C1.$$methods`
#   p `Opal.C2.$$methods`
# else
#   p C1.instance_methods
#   p C2.instance_methods
# end
