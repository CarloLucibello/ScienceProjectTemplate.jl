
"""
Check if a file with the name exists, if so, append a number to the name.
"""
function check_filename(filename)
    mkpath(dirname(filename))
    i = 1
    _filename = filename
    while isfile(_filename)
        i += 1
        _filename = filename * "." * string(i)
    end
    filename = _filename
    return filename
end

"""
    cartesian_list(; kws...)

Return a vector containing all of the combinations of the values in the keyword arguments.
Similar to `collect(Iterators.product(kws...))` 
and to [`DrWatson.dict_list`](@ref) but returns a vector of `NamedTuple`s.

# Example

```julia
julia> cartesian_list(a = [1,2], b = [3,4])
2-element Vector{NamedTuple{(:a, :b),Tuple{Int64,Int64}}}:
 (a = 1, b = 3)
 (a = 1, b = 4)
 (a = 2, b = 3)
 (a = 2, b = 4)
```
"""
function cartesian_list(; kws...)
    dlist = dict_list(Dict(kws...))
    return [(; (k => d[k] for (k,_) in kws)...) for d in dlist]
end

"""
    subseteq(df; col1=val1, col2=val2, ...)

Return a subset of `df` where the values of the columns `col1`, `col2`, ..., 
are equal to `val1`, `val2`, ... .

# Examples

```julia

julia> df = DataFrame(a=[1,2,3,1], b=[4,5,6,4], c=[7,8,9,10])
4×3 DataFrame
 Row │ a      b      c     
     │ Int64  Int64  Int64 
─────┼─────────────────────
   1 │     1      4      7
   2 │     2      5      8
   3 │     3      6      9
   4 │     1      4     10

julia> subseteq(df, a=1, b=4)
2×3 DataFrame
 Row │ a      b      c     
     │ Int64  Int64  Int64 
─────┼─────────────────────
   1 │     1      4      7
   2 │     1      4     10
```
"""
subseteq(df; kws...) = DataFrames.subset(df, (k => x -> x .== v for (k, v) in kws)...)


# PIRACY!
function Base.merge(s::OrderedDict, nt::NamedTuple)
    snew = deepcopy(s)
    for (k, v) in pairs(nt)
        snew[k] = v 
    end
    return snew
end
