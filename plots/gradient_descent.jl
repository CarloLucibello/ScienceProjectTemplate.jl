using ScienceProjectTemplate
using DrWatson
using DataFrames, CSV
using Plots, StatsPlots

# function data_analysis()
respath = datadir("raw", "gradient_descent")
files = [joinpath(respath, file) for file in readdir(respath) 
         if !(contains(file, "nsamples=1.") || contains(file, "nsamples=1_"))]

dfs = [CSV.read(file) for file in files]
df = reduce(vcat, dfs)

function combine_results(df; par_idxs, res_idxs, err_idxs = res_idxs .+ 1)
    par_cols = Symbol.(names(df)[par_idxs])
    res_cols = Symbol.(names(df)[res_idxs])
    err_cols = Symbol.(names(df)[err_idxs])
       
    gd = groupby(df, par_cols)

    function reduce_measurements(df)
        nsamples = sum(df.nsamples)
        dmeans = Dict(col => sum(df[!,col] .* df.nsamples) / nsamples for col in res_cols)
        
        function meansq(col, err_col)
            sumresidues = df[!,err_col].^2 .* df.nsamples .* (df.nsamples .- 1)
            return sum(sumresidues .+ df[!,col].^2 .* df.nsamples) / (nsamples-1)
        end
        
        function err_on_mean(col, err_col)
            s = meansq(col, err_col) - dmeans[col].^2
            return sqrt(s / nsamples)
        end
        
        derrs = Dict(err_col => err_on_mean(col, err_col) for (col, err_col) in zip(res_cols, err_cols))
        
        means_with_errs =  reduce(vcat, [[col => dmeans[col], err_col => derrs[err_col]] 
                                    for (col, err_col) in zip(res_cols, err_cols)])

        return (; nsamples, means_with_errs...)  
    end

    dfnew = combine(reduce_measurements, gd, threads=false)

    return dfnew
end


df_N40 = subseteq(df; α=0.2, N = 40)
df_N50 = subseteq(df; α=0.2, N = 50)
df_N60 = subseteq(df; α=0.2, N = 60)
df_N70 = subseteq(df; α=0.2, N = 70)


plot(title = "Final dist. from init. cond. of GD. α=$α",
    xlabel = "λ", 
    ylabel = "Δ", 
    legend = :topright)
   
@df df_N40 plot!(:λ, :Δ0, yerr = :Δ0_err, label = "N = 70", msc=:auto)
