"""
    Stats() <: OnlineStats.OnlineStat

A type for collecting statistics. 

# Examples

```julia
julia> using OnlineStats

julia> s = Stats();

julia> OnlineStats.fit!(s, (a = 1, b = 2));  # add one datapoint at a time

julia> OnlineStats.fit!(s, Dict(:a => 2, :b => 3, :c=>4)); # also support dicts and new observables

julia> OnlineStats.nobs(s)
2

julia> data = [(a = i, b = 2*i) for i in 1:10];

julia> OnlineStats.fit!(s, data);  # add multiple datapoints

julia> OnlineStats.nobs(s)
12

julia> s.a      # mean and error (as a Measurements.jl type)
1.5 ± 0.25

# reduce interface

julia> reduce(Stats(), data)
Stats:
  a = 5.5 ± 0.92        (10 obs)
  b = 11.0 ± 3.7        (10 obs)
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
        return OnlineStats.value(x[1]) ± (OnlineStats.value(x[2]) / OnlineStats.nobs(x[2]))
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

Statistics.mean(s::Stats) = OrderedDict(k => OnlineStats.value(v.stats[1]) for (k,v) in pairs(s))
Statistics.var(s::Stats) = OrderedDict(k => OnlineStats.value(v.stats[2]) for (k,v) in pairs(s))

function mean_with_err(s::Stats)
    d = OrderedDict{Symbol,Any}()
    for (k, v) in pairs(s)
        d[k] = OnlineStats.value(v.stats[1])
        d[Symbol(k, "_err")] = sqrt(OnlineStats.value(v.stats[2]) / v.stats[2].n)
    end
    return d
end

function Base.show(io::IO, s::Stats)
    println(io, "Stats:")
    for k in keys(s)
        m = getproperty(s, k)
        n = OnlineStats.nobs(s[k])  
        println(io, "  $(k) = $(m)\t($(n) obs)")
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

