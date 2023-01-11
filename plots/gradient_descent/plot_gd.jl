using ScienceProjectTemplate
using DrWatson
using DataFrames, DataFramesMeta, CSV
using Plots, StatsPlots

# function data_analysis()
respath = datadir("raw", "gradient_descent")
files = [joinpath(respath, file) for file in readdir(respath) 
         if !(contains(file, "nsamples=1.") || contains(file, "nsamples=1_"))]

dfs = [CSV.read(file, DataFrame) for file in files]
df = reduce(vcat, dfs)

df = combine_results(df, by = 1:3, 
            cols = 5:2:ncol(df), 
            errs = 6:2:ncol(df), 
            col_n = :nsamples)

# Use DataFramesMeta for row selection
df_N40 = @rsubset(df, :α == 0.2, :N == 40)
df_N50 = @rsubset(df, :α == 0.2, :N == 50)
df_N60 = @rsubset(df, :α == 0.2, :N == 60)
df_N70 = @rsubset(df, :α == 0.2, :N == 70)

plot(title = "Final loss GD vs L2 regularize parameter λ",
    xlabel = "λ",  ylabel = "E", legend = :topright)
   
@df df_N40 plot!(:λ, :E, yerr=:E_err, label = "N = 40", msc=:auto)
savefig(plotsdir("gradient_descent", "fig_E_vs_λ.pdf"))
