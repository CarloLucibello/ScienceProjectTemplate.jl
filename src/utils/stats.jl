
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
        return getindex(s, k)
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

_init_stat() = Series(Mean(), Variance())

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

Base.show(io::IO, s::Stats) = show(io, s._stats)

# Binary op interface for reduce/mapreduce
function (s::Stats)(x, y)
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

