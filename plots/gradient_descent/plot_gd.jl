using ScienceProjectTemplate
using DrWatson
using DataFrames, DataFramesMeta, CSV
using Plots, StatsPlots
using Glob

respath = datadir("raw", "gradient_descent")
files = [file for file in glob("*.csv*", respath) if !contains(file, "nsamples=1_")]

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

# Single Plot
plot(title = "Final loss GD vs L2 regularize parameter λ",
    xlabel = "λ",  ylabel = "E", legend = :topright)
   
@df df_N40 plot!(:λ, :E, yerr=:E_err, label = "N = 40", msc=:auto)
savefig(plotsdir("gradient_descent", "fig_E_vs_λ.pdf"))

# Subplots
p1 = @df df_N40 plot(:λ, :E, yerr=:E_err, label = "N = 40", msc=:auto)
p2 = @df df_N50 scatter(:λ, :E, label = "N = 50")
p3 = @df df_N50 plot(:λ, :E, label = "N = 60")
p = plot(p1, p2, p3, layout = (3, 1), legend = :topright, title="ciao")

# more complex layout
layout = @layout [a; b c]
p = plot(p1, p2, p3; layout,
    title = ["t1" "t2" "t3"], # individual titles
    plot_title="supertitle", plot_titlevspan=0.1)
