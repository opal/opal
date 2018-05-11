class A
end

module M
end

class B < A
  include M
end

%x{
  function printMap(mod) {
    if (mod.hasOwnProperty('$$is_singleton')) {
      console.log(`singleton<${mod.$$singleton_of.$$name}>`);
    } else {
      console.log(mod.$$name);
    }

    mod.$$children.forEach(mod => printMap(mod))
  }

  printMap(Opal.BasicObject);

  debugger;
}

123

