module ScienceProjectTemplate

using OnlineStats: OnlineStats
using DrWatson: DrWatson, dict_list
using OrderedCollections: OrderedDict

include("utils/stats.jl")
export Stats

include("utils/misc.jl")
export check_filename, dict_list


end # module