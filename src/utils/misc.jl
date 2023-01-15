
"""
    check_filename(filename)

Check if a file with the name `filename` exists, if so, append a number to the name.
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

# Examples

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
    dlist = dict_list(_cartesian_kws_to_dict(kws))
    return [(; (k => d[k] for (k,_) in kws)...) for d in dlist]
end

_cartesian_kws_to_dict(kws) = Dict(k => _collect_if_vec(v) for (k,v) in pairs(kws))
_collect_if_vec(x::AbstractVector) = collect(x)
_collect_if_vec(x) = x

"""
    combine_results(df; by, cols, errs = nothing, col_n = :nsamples)

Combine the results of measurements in `df` by averaging the values in `cols`
grouped by the columns in `by` and 
propagating the errors in `errs` using the number of samples in `col_n`.

If no errors are given, the standard deviation on the mean is used as the error.

The final error is given by `sqrt(var / (n*(n-1)))` where var is the variance
and `n` is the total number of samples.

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


julia> df = DataFrame(a=[1,1,3,1], b=[1,2,6,3], c=[7,8,9,10])
4×3 DataFrame
Row │ a      b      c     
    │ Int64  Int64  Int64 
─────┼─────────────────────
    1 │     1      1      7
    2 │     1      2      8
    3 │     3      6      9
    4 │     1      3     10


julia> combine_results(df, by=:a, cols=:b)
2×4 DataFrame
Row │ a      nsamples  b        b_err     
    │ Int64  Int64     Float64  Float64   
─────┼─────────────────────────────────────
    1 │     1         3      2.0    0.57735
    2 │     3         1      6.0  Inf
```
"""
function combine_results(df::DataFrame; 
        by, 
        cols, 
        errs = nothing, 
        col_n::Symbol = :nsamples)

    par_cols = normalize_colnames(df, by)
    val_cols = normalize_colnames(df, cols)

    if errs !== nothing
        @assert length(cols) == length(errs)
        err_cols = normalize_colnames(df, errs)
    else
        err_cols = [Symbol(k, "_err") for k in val_cols]
    end

    function reduce_measurements(df)
        if errs === nothing
            nsamples = ones(Int, nrow(df))
        else
            nsamples = df[!, col_n]
        end
        totsamples = sum(nsamples)
        dmeans = Dict(col => sum(df[!,col] .* nsamples) / totsamples for col in val_cols)

        function sumsq(col, err_col)
            sumresidues = map(df[!,err_col], nsamples) do e, n 
                n > 1 ? e^2 * n * (n - 1) : 0.0
            end

            return sum(sumresidues .+ df[!,col].^2 .* nsamples)
        end

        function err_on_mean(col, err_col)
            if errs === nothing
                s = var(df[!,col]) * (totsamples - 1)
            else
                s = sumsq(col, err_col) - dmeans[col]^2 * totsamples
            end
            if totsamples == 1
                return Inf
            else
                return sqrt(s / (totsamples * (totsamples - 1)) + 1e-16)
            end
        end
        
        derrs = Dict(err_col => err_on_mean(col, err_col) for (col, err_col) in zip(val_cols, err_cols))
        
        means_with_errs =  reduce(vcat, [[col => dmeans[col], err_col => derrs[err_col]] 
                                          for (col, err_col) in zip(val_cols, err_cols)])

        return (; [col_n => totsamples]..., means_with_errs...)  
    end

    gd = groupby(df, par_cols)
    dfnew = combine(reduce_measurements, gd)
    return dfnew
end

normalize_colnames(df, k::Integer) = Symbol.([names(df)[k]])
normalize_colnames(df, k::AbstractVector{<:Integer}) = Symbol.(names(df)[k])
normalize_colnames(df, k::Symbol) = [k]
normalize_colnames(df, k::AbstractVector{<:Symbol}) = k
normalize_colnames(df, k::AbstractString) = [Symbol(k)]
normalize_colnames(df, k::AbstractVector{<:AbstractString}) = Symbol.(k)

function Base.merge(s::OrderedDict, nt::NamedTuple)
    snew = deepcopy(s)
    for (k, v) in pairs(nt)
        snew[k] = v 
    end
    return snew
end


## I/O
"""
    round3(x)

If `x` is a floating point number, round `x` to 3 significant digits. 
If `x` is a container of numers, round its content.
"""
round3(x) = round(x, sigdigits=3)
round3(x::NamedTuple) = map(round3, x)
round3(x::Integer) = x
round3(x::AbstractArray) = round.(x, sigdigits=3)
