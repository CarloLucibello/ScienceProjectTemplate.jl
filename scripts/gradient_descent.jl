# This is an example script demonstrating a pattern for parallel runs.
# Launch julia with `julia -t X` to use X threads.


using DrWatson
using ScienceProjectTemplate

using LinearAlgebra, Random, Statistics
using DataFrames, CSV
using BenchmarkTools
using ThreadsX

Threads.nthreads() > 1 && BLAS.set_num_threads(1) 
# BLAS.set_num_threads(Sys.CPU_THREADS) # default value

function f_single_run(; N = 50,
                    α = 0.2,
                    η = 0.5,
                    nsamples = 1,
                    λ = 0.1,
                    maxsteps = 1000)
    
    if nsamples == 1
        # Dummy return for demonstration purpose
        # Can be a NamedTuple, a Dict, or an OrderedDict 
        return (t = rand(1:100), E = rand())  
    else 
        stats = ThreadsX.mapreduce(Stats(), 1:nsamples) do _  # remove ThreadsX. for single thread
            return (t = rand(1:100), E = rand())            
        end
        return mean_with_err(stats)
    end
end


function parallel_run(;
        N = 40,
        α = 0.2,
        λ = [0.1:0.1:1.0;],
        nsamples = 1,
        resfile = savename("run_"*gethostname(), (; N, α, nsamples), "csv", digits=4),
        respath = datadir("raw", splitext(basename(@__FILE__))[1]), # defaults to data/raw/SCRIPTNAME 
        kws...)

    params_list = cartesian_list(; N, α, λ, nsamples)
    
    allres = ThreadsX.map(params_list) do p     # remove ThreadsX. for single threaded run
        res = f_single_run(; p..., kws...)
        return merge(p, res)
    end

    df = DataFrame(allres)
    if resfile != "" && resfile !== nothing
        path = joinpath(respath, resfile)
        path = check_filename(path) # appends a number if the file already exists
        CSV.write(path, df)
    end
    return df
end


# same as parallel_run but prints while looping
function parallel_run_v2(;
        N = 40,
        α = 0.2,
        λ = [0.1:0.1:1.0;],
        nsamples = 1,
        resfile = savename("run_"*gethostname(), (; N, α, nsamples), "csv", digits=4),
        respath = datadir("raw", splitext(basename(@__FILE__))[1]), # defaults to data/raw/SCRIPTNAME 
        kws...)

    if resfile != "" && resfile !== nothing
        resfile = joinpath(respath, resfile)
        resfile = check_filename(resfile) # appends a number if the file already exists
        touch(resfile)
    end
    
    params_list = cartesian_list(; N, α, λ, nsamples)
    
    lck = ReentrantLock()
    df = DataFrame()
    ThreadsX.foreach(params_list) do p     # remove ThreadsX. for single threaded run
        res = f_single_run(; p..., kws...)
        lock(lck) do 
            push!(df, merge(p, res))
            if resfile != "" && resfile !== nothing
                CSV.write(resfile, df)
            end
        end
    end

    return df
end

## use @btime and @profview for profiling
# @btime f_single_run()
# @time parallel_run(N=40, nsamples=100, α=0.2)


