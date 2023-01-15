# This is an example script demonstrating a pattern for parallel runs.
# Launch julia with `julia --project=@. -p n` to use n processes. 

using Distributed


@everywhere begin
    using DrWatson
    using ScienceProjectTemplate

    using LinearAlgebra, Random, Statistics
    using DataFrames, CSV
    using BenchmarkTools

    BLAS.set_num_threads(1) 

    function f_single_run(; N = 50,
                        α = 0.2,
                        η = 0.5,
                        nsamples = 1,
                        λ = 0.1,
                        maxsteps = 1000)
        
        if nsamples == 1
            return (t = rand(1:100), E = rand())  
        else 
            stats = mapreduce(Stats(), 1:nsamples) do _ 
                return (t = rand(1:100), E = rand())            
            end
            return mean_with_err(stats)
        end
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
        touch(resfile)
    end

    params_list = cartesian_list(; N, α, λ, nsamples)
    
    rows = pmap(params_list) do p     # remove ThreadsX. for single threaded run
        res = f_single_run(; p..., kws...)
        row = merge(p, res)
        if resfile != ""
            resfileproc = resfile * "-$(Distributed.myid())"
            fileexists = isfile(resfileproc)
            if fileexists
                df = CSV.read(resfileproc, DataFrame)
                counter = size(df, 1) + 1
            else
                counter = 1
            end
            CSV.write(resfileproc, [row]; append = true, writeheader = !fileexists)
            @info "Done $counter of $(length(params_list)) on worker $(Distributed.myid())" round3(p) round3(res)
            @info "Saved to $resfileproc"
        end
        return row
    end

    df = DataFrame(rows)
    # if resfile != ""
    #     CSV.write(resfile, df)
    # end
    return df
end



## use @btime and @profview for profiling
# @btime f_single_run()
# @time parallel_run(N=40, nsamples=100, α=0.2)


