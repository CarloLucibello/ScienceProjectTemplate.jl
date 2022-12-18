# ScienceProjectTemplate

[![](https://img.shields.io/badge/docs-dev-blue.svg)](https://CarloLucibello.github.io/ScienceProjectTemplate.jl/dev)
![](https://github.com/CarloLucibello/ScienceProjectTemplate.jl/actions/workflows/ci.yml/badge.svg)
[![codecov](https://codecov.io/gh/CarloLucibello/ScienceProjectTemplate.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/CarloLucibello/ScienceProjectTemplate.jl)

A template for boostrapping scientific projects containing Julia code.

Clone the repo, then replace `ScienceProjectTemplate` everywhere with the name of your project.

# Use as a package

As an alternative to using this repo as a template, you can use it as an imported package
in your code and enjoy the utility functions it offers. 

ScienceProjectTemplate is not a registered package, therefore you will have to
add it with 

```julia
# hit ] in the Julia REPL, then
pkg> add https://github.com/CarloLucibello/ScienceProjectTemplate.jl
```

After that, you will be able to import the library and its types/methods in your code, for example: 
```julia
using ScienceProjectTemplate: Stats 
```

Using ScienceProjectTemplate as a library can be risky since the package is experimental and 
not yet versioned, therefore your code could break at some point.

