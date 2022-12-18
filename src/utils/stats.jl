"""
    Stats() <: OnlineStat

A type for collecting statistics. 

# Examples

```julia
julia> using OnlineStats

julia> s = Stats();

julia> OnlineStats.fit!(s, (a = 1, b = 2));  # add one datapoint at a time

julia> OnlineStats.fit!(s, Dict(:a => 2, :b => 3, :c=>4)); # also support dicts and new observables

julia> s
Stats:
  a  =  1.5 ± 0.5       (2 obs)
  b  =  2.5 ± 0.5       (2 obs)
  c  =  4.0 ± Inf       (1 obs)

julia> data = [(a = i, b = 2*i) for i in 1:10];

julia> OnlineStats.fit!(s, data);  # add multiple datapoints

julia> OnlineStats.nobs(s)
12

julia> s.a      # mean and error (as a Measurements.jl type)
4.83 ± 0.91

julia> reduce(Stats(), data)
Stats:
  a  =  5.5 ± 0.96      (10 obs)
  b  =  11.0 ± 1.9      (10 obs)
"""
struct Stats <: OnlineStat{Union{NamedTuple, AbstractDict{Symbol}}}
    _stats::OrderedDict{Symbol, OnlineStat}
end

function Stats()
    stats = OrderedDict{Symbol, Any}()
    return Stats(stats)
end

Base.getindex(s::Stats, k::Symbol) = getindex(s._stats, k)
Base.keys(s::Stats) = keys(s._stats)
Base.pairs(s::Stats) = pairs(s._stats)
Base.setindex!(s::Stats, v, k::Symbol) = setindex!(s._stats, v, k)
Base.haskey(s::Stats, k::Symbol) = haskey(s._stats, k)
Base.length(s::Stats) = length(s._stats)
Base.values(s::Stats) = values(s._stats)


function Base.getproperty(s::Stats, k::Symbol)
    if hasfield(Stats, k)
        return getfield(s, k)
    else
        x = getfield(s, :_stats)[k].stats
        n = OnlineStats.nobs(x[1])
        μ = OnlineStats.value(x[1])
        σ = n == 1 ? Inf : sqrt(OnlineStats.value(x[2]) / n)
        return μ ± σ
    end
end

function OnlineStats._fit!(s::Stats, x::Union{NamedTuple, AbstractDict{Symbol}})
    for (k, v) in pairs(x)
        if !haskey(s, k)
            s[k] = _init_stat()
        end
        OnlineStats.fit!(s[k], v)
    end
end

_init_stat() = OnlineStats.Series(OnlineStats.Mean(), OnlineStats.Variance())

Base.empty!(s::Stats) = s._stats = OrderedDict{Symbol, Any}()

function OnlineStats._merge!(s1::Stats, s2::Stats)
    for (k, v) in pairs(s2._stats)
        if !haskey(s1, k)
            s1[k] = v
        end
        OnlineStats.merge!(s1[k], v)
    end
end

OnlineStats.nobs(s::Stats) = length(s._stats) > 0 ? OnlineStats.nobs(first(values(s))) : 0

OnlineStats.value(s::Stats) = Statistics.mean(s)

Statistics.mean(s::Stats) = (; (k => OnlineStats.value(v.stats[1]) for (k,v) in pairs(s))...)
Statistics.var(s::Stats) = (; (k => OnlineStats.value(v.stats[2]) for (k,v) in pairs(s))...)

function mean_with_err(s::Stats)
    d = OrderedDict{Symbol,Any}()
    m = measurement(s)
    for (k, v) in pairs(m)
        d[k] = v.val
        d[Symbol(k, "_err")] = v.err
    end
    return (; d...)
end

Measurements.measurement(s::Stats) = (; (k => getproperty(s, k) for k in keys(s))...)

function Base.show(io::IO, s::Stats)
    if OnlineStats.nobs(s) == 0
        print(io, "Stats object with 0 observations")
    else
        print(io, "Stats:")
    end
    for k in keys(s)
        m = getproperty(s, k)
        n = OnlineStats.nobs(s[k])  
        print(io, "\n  $(k)  =  $(m)\t($(n) obs)")
    end
end

# Binary op interface for reduce/mapreduce
function (s::Stats)(x, y)
    @assert OnlineStats.nobs(s) == 0
    OnlineStats.fit!(s, x)
    OnlineStats.fit!(s, y)
    return s
end

# Binary op interface for reduce/mapreduce
function (s::Stats)(x::Stats, y)
    @assert s === x
    OnlineStats.fit!(s, y)
    return s
end

