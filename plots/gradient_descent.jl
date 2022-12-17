using ScienceProjectTemplate
using DrWatson
using DataFrames, CSV
using Plots, StatsPlots

# function data_analysis()
respath = datadir("raw", "gradient_descent")
files = [joinpath(respath, file) for file in readdir(respath) 
         if !(contains(file, "nsamples=1.") || contains(file, "nsamples=1_"))]

dfs = [CSV.read(file, DataFrame) for file in files]
df = reduce(vcat, dfs)

combine_results(df, by = 1:3, cols = 5:2:ncol(df), col_n = :nsamples)

df_N40 = subseteq(df; α=0.2, N = 40)
df_N50 = subseteq(df; α=0.2, N = 50)
df_N60 = subseteq(df; α=0.2, N = 60)
df_N70 = subseteq(df; α=0.2, N = 70)


plot(title = "Final dist. from init. cond. of GD. α=$α",
    xlabel = "λ", 
    ylabel = "Δ", 
    legend = :topright)
   
@df df_N40 plot!(:λ, :Δ0, yerr = :Δ0_err, label = "N = 70", msc=:auto)
