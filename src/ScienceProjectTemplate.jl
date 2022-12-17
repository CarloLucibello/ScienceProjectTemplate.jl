module ScienceProjectTemplate

using Random, Statistics, LinearAlgebra
using OnlineStats: OnlineStats, OnlineStat
using DrWatson: DrWatson, dict_list
using OrderedCollections: OrderedDict
using Measurements

include("utils/stats.jl")
export Stats, mean_with_err

include("utils/misc.jl")
export check_filename, cartesian_list


end # module