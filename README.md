# R-Stock-Portfolio-Optimization
Efficiently gathering data from stocks to be used in optimizing a portfolio. The data is sent to AMPL, optimized there, and sent back to R to analyze/visualize the results.

The R code is given with the .R extension as expected. AMPL (A Mathematical Programing Language) files are given with the extensions .mod, .dat, .run. The .mod file contains the general formulation of this kind of optimization problem, the .dat file contains the data gathered from the R script, and finally the .run file runs the model iterating over varying risk levels. 
