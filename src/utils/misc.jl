
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

"""
    combine_results(df; by, cols, errs, col_n = :nsamples)

Combine the results of measurements in `df` by averaging the values in `cols`
grouped by the columns in `by` and 
propagating the errors in `errs` using the number of samples in `col_n`.

# Examples

```julia
julia> using DataFrames

julia> df = DataFrame(a = [1,1,3], b=[2,2,4], n = [2,3,4], c = [2.,2.1,4.], c_err = [0.2,0.1,0.2])
3×5 DataFrame
 Row │ a      b      n      c        c_err   
     │ Int64  Int64  Int64  Float64  Float64 
─────┼───────────────────────────────────────
   1 │     1      2      2      2.0      0.2
   2 │     1      2      3      2.1      0.1
   3 │     3      4      4      4.0      0.2

julia> combine_results(df, by=1:2, cols=4:2:ncol(df), errs=5:2:ncol(df), col_n=:n)
2×5 DataFrame
 Row │ a      b      n      c        c_err    
     │ Int64  Int64  Int64  Float64  Float64  
─────┼────────────────────────────────────────
   1 │     1      2      5     2.06  0.087178
   2 │     3      4      4     4.0   0.2
```
"""
function combine_results(df::DataFrame; 
        by, 
        cols, 
        errs, 
        col_n::Symbol = :nsamples)

    par_cols = Symbol.(names(df)[by])
    val_cols = Symbol.(names(df)[cols])
    err_cols = Symbol.(names(df)[errs])

    gd = groupby(df, par_cols)

    function reduce_measurements(df)
        nsamples = df[!, col_n]
        totsamples = sum(nsamples)
        dmeans = Dict(col => sum(df[!,col] .* nsamples) / totsamples for col in val_cols)
        
        function sumsq(col, err_col)
            sumresidues = map(df[!,err_col], nsamples) do e, n 
                n > 1 ? e^2 * n * (n - 1) : 0.0
            end

            return sum(sumresidues .+ df[!,col].^2 .* nsamples)
        end

        function err_on_mean(col, err_col)
            s = sumsq(col, err_col) - dmeans[col]^2 * totsamples
            if totsamples == 1
                return Inf
            else
                return sqrt(s / (totsamples * (totsamples - 1)))
            end
        end
        
        derrs = Dict(err_col => err_on_mean(col, err_col) for (col, err_col) in zip(val_cols, err_cols))
        
        means_with_errs =  reduce(vcat, [[col => dmeans[col], err_col => derrs[err_col]] 
                                    for (col, err_col) in zip(val_cols, err_cols)])

        return (; [col_n => totsamples]..., means_with_errs...)  
    end

    dfnew = combine(reduce_measurements, gd)
    return dfnew
end

# PIRACY!
function Base.merge(s::OrderedDict, nt::NamedTuple)
    snew = deepcopy(s)
    for (k, v) in pairs(nt)
        snew[k] = v 
    end
    return snew
end
