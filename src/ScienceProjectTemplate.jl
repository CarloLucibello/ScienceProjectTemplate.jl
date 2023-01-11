module ScienceProjectTemplate

using Random, Statistics, LinearAlgebra
using OnlineStats: OnlineStats, OnlineStat
using DrWatson: DrWatson, dict_list
using OrderedCollections: OrderedDict
using Measurements
using DataFrames

include("utils/stats.jl")
export Stats, mean_with_err

include("utils/misc.jl")
export check_filename, cartesian_list, combine_results


end # module