
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

# PIRACY!
function Base.merge(s::OrderedDict, nt::NamedTuple)
    snew = deepcopy(s)
    for (k, v) in pairs(nt)
        snew[k] = v 
    end
    return snew
end
