# This is an example script demonstrating a pattern for parallel runs.
# Launch julia with `--project=@. -t n` to use n threads.


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
        resfile = nothing,
        respath = nothing, # defaults to data/raw/SCRIPTNAME 
        kws...)

    if respath === nothing
        respath = datadir("raw", "gradient_descent")
    end
    if resfile === nothing
        resfile = savename("run_"*gethostname(), (; N, α, nsamples), "csv", digits=4)
    end
    if resfile != ""
        resfile = joinpath(respath, resfile)
        resfile = check_filename(resfile) # appends a number if the file already exists
    end

    params_list = cartesian_list(; N, α, λ, nsamples)
    
    rows = ThreadsX.map(params_list) do p     # remove ThreadsX. for single threaded run
        res = f_single_run(; p..., kws...)
        return merge(p, res)
    end

    df = DataFrame(rows)
    if resfile != ""
        CSV.write(resfile, df)
    end
    return df
end


# same as parallel_run but prints while looping
function parallel_run_v2(;
        N = 40,
        α = 0.2,
        λ = [0.1:0.1:1.0;],
        nsamples = 1,
        resfile = nothing,
        respath = nothing, # defaults to data/raw/SCRIPTNAME 
        kws...)

    if respath === nothing
        respath = datadir("raw", "gradient_descent")
    end
    if resfile === nothing
        resfile = savename("run_"*gethostname(), (; N, α, nsamples), "csv", digits=4)
    end
    if resfile != ""
        resfile = joinpath(respath, resfile)
        resfile = check_filename(resfile) # appends a number if the file already exists
    end
    
    params_list = cartesian_list(; N, α, λ, nsamples)
    
    lck = ReentrantLock()
    df = DataFrame()
    counter = 0
    ThreadsX.foreach(params_list) do p     # remove ThreadsX. for single threaded run
        res = f_single_run(; p..., kws...)
        lock(lck) do 
            counter += 1
            row = merge(p, res)
            push!(df, row)
            @info "Finished $counter of $(length(params_list))" round3(p) round3(res)
            if resfile != ""
                CSV.write(resfile, [row]; append = true, writeheader = counter == 1)
                @info "Saved to $resfile"
            end
        end
    end

    sort!(df, [:N, :α, :λ])
    if resfile != ""
        CSV.write(resfile, df)
    end
    return df
end

## use @btime and @profview for profiling
# @btime f_single_run()
# @time parallel_run(N=40, nsamples=100, α=0.2)


