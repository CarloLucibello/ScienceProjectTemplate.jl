var documenterSearchIndex = {"docs":
[{"location":"api/#API","page":"API","title":"API","text":"","category":"section"},{"location":"api/#Index","page":"API","title":"Index","text":"","category":"section"},{"location":"api/","page":"API","title":"API","text":"Order = [:type, :function]\nPages   = [\"api.md\"]","category":"page"},{"location":"api/#Docs","page":"API","title":"Docs","text":"","category":"section"},{"location":"api/#Stats","page":"API","title":"Stats","text":"","category":"section"},{"location":"api/","page":"API","title":"API","text":"Modules = [ScienceProjectTemplate]\nPages   = [\"utils/stats.jl\"]\nPrivate = false","category":"page"},{"location":"api/#ScienceProjectTemplate.Stats","page":"API","title":"ScienceProjectTemplate.Stats","text":"Stats() <: OnlineStat\n\nA type for collecting statistics. \n\nExamples\n\njulia> using OnlineStats\n\njulia> s = Stats();\n\njulia> OnlineStats.fit!(s, (a = 1, b = 2));  # add one datapoint at a time\n\njulia> OnlineStats.fit!(s, Dict(:a => 2, :b => 3, :c=>4)); # also support dicts and new observables\n\njulia> s\nStats:\n  a  =  1.5 ± 0.5       (2 obs)\n  b  =  2.5 ± 0.5       (2 obs)\n  c  =  4.0 ± Inf       (1 obs)\n\njulia> data = [(a = i, b = 2*i) for i in 1:10];\n\njulia> OnlineStats.fit!(s, data);  # add multiple datapoints\n\njulia> OnlineStats.nobs(s)\n12\n\njulia> s.a      # mean and error (as a Measurements.jl type)\n4.83 ± 0.91\n\njulia> reduce(Stats(), data)\nStats:\n  a  =  5.5 ± 0.96      (10 obs)\n  b  =  11.0 ± 1.9      (10 obs)\n\n\n\n\n\n","category":"type"},{"location":"api/#Misc","page":"API","title":"Misc","text":"","category":"section"},{"location":"api/","page":"API","title":"API","text":"Modules = [ScienceProjectTemplate]\nPages   = [\"utils/misc.jl\"]\nPrivate = false","category":"page"},{"location":"api/#ScienceProjectTemplate.cartesian_list-Tuple{}","page":"API","title":"ScienceProjectTemplate.cartesian_list","text":"cartesian_list(; kws...)\n\nReturn a vector containing all of the combinations of the values in the keyword arguments. Similar to collect(Iterators.product(kws...))  and to DrWatson.dict_list but returns a vector of NamedTuples.\n\nExamples\n\njulia> cartesian_list(a = [1,2], b = [3,4])\n2-element Vector{NamedTuple{(:a, :b),Tuple{Int64,Int64}}}:\n (a = 1, b = 3)\n (a = 1, b = 4)\n (a = 2, b = 3)\n (a = 2, b = 4)\n\n\n\n\n\n","category":"method"},{"location":"api/#ScienceProjectTemplate.check_filename-Tuple{Any}","page":"API","title":"ScienceProjectTemplate.check_filename","text":"check_filename(filename)\n\nCheck if a file with the name filename exists, if so, append a number to the name.\n\n\n\n\n\n","category":"method"},{"location":"api/#ScienceProjectTemplate.combine_results-Tuple{DataFrames.DataFrame}","page":"API","title":"ScienceProjectTemplate.combine_results","text":"combine_results(df; by, cols, errs = nothing, col_n = :nsamples)\n\nCombine the results of measurements in df by averaging the values in cols grouped by the columns in by and  propagating the errors in errs using the number of samples in col_n.\n\nIf no errors are given, the standard deviation on the mean is used as the error.\n\nThe final error is given by sqrt(var / (n*(n-1))) where var is the variance and n is the total number of samples.\n\nExamples\n\njulia> using DataFrames\n\njulia> df = DataFrame(a = [1,1,3], b=[2,2,4], n = [2,3,4], c = [2.,2.1,4.], c_err = [0.2,0.1,0.2])\n3×5 DataFrame\n Row │ a      b      n      c        c_err   \n     │ Int64  Int64  Int64  Float64  Float64 \n─────┼───────────────────────────────────────\n   1 │     1      2      2      2.0      0.2\n   2 │     1      2      3      2.1      0.1\n   3 │     3      4      4      4.0      0.2\n\njulia> combine_results(df, by=1:2, cols=4:2:ncol(df), errs=5:2:ncol(df), col_n=:n)\n2×5 DataFrame\n Row │ a      b      n      c        c_err    \n     │ Int64  Int64  Int64  Float64  Float64  \n─────┼────────────────────────────────────────\n   1 │     1      2      5     2.06  0.087178\n   2 │     3      4      4     4.0   0.2\n\n\njulia> df = DataFrame(a=[1,1,3,1], b=[1,2,6,3], c=[7,8,9,10])\n4×3 DataFrame\nRow │ a      b      c     \n    │ Int64  Int64  Int64 \n─────┼─────────────────────\n    1 │     1      1      7\n    2 │     1      2      8\n    3 │     3      6      9\n    4 │     1      3     10\n\n\njulia> combine_results(df, by=:a, cols=:b)\n2×4 DataFrame\nRow │ a      nsamples  b        b_err     \n    │ Int64  Int64     Float64  Float64   \n─────┼─────────────────────────────────────\n    1 │     1         3      2.0    0.57735\n    2 │     3         1      6.0  Inf\n\n\n\n\n\n","category":"method"},{"location":"api/#ScienceProjectTemplate.round3-Tuple{Any}","page":"API","title":"ScienceProjectTemplate.round3","text":"round3(x)\n\nIf x is a floating point number, round x to 3 significant digits.  If x is a container of numers, round its content.\n\n\n\n\n\n","category":"method"},{"location":"#Science-Project-Template","page":"Home","title":"Science Project Template","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"A template for boostrapping scientific projects containing Julia code.","category":"page"},{"location":"","page":"Home","title":"Home","text":"Clone the repo, then replace ScienceProjectTemplate everywhere with the name of your project.","category":"page"},{"location":"#Use-as-a-package","page":"Home","title":"Use as a package","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"As an alternative to using this repo as a template, you can use it as an imported package in your code and enjoy the utility functions it offers. ","category":"page"},{"location":"","page":"Home","title":"Home","text":"ScienceProjectTemplate is not a registered package, therefore you will have to add it with ","category":"page"},{"location":"","page":"Home","title":"Home","text":"# hit ] in the Julia REPL, then\npkg> add https://github.com/CarloLucibello/ScienceProjectTemplate.jl","category":"page"},{"location":"","page":"Home","title":"Home","text":"After that, you will be able to import the library and its types/methods in your code, for example: ","category":"page"},{"location":"","page":"Home","title":"Home","text":"using ScienceProjectTemplate: Stats ","category":"page"},{"location":"","page":"Home","title":"Home","text":"Using ScienceProjectTemplate as a library can be risky since the package is experimental and  not yet versioned, therefore your code could break at some point.","category":"page"}]
}
