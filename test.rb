module M1; end
module M2; end
module M3; include M1; end

p M3.ancestors
M1.include(M2)
p M3.ancestors
M3.include(M1)
`debugger;`
p M3.ancestors
# ModuleSpecs::MultipleIncludes.include(ModuleSpecs::MB)
# p ModuleSpecs::MultipleIncludes.ancestors
# p [ModuleSpecs::MA, ModuleSpecs::MB, ModuleSpecs::MC]
