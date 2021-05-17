library(tidyquant)
library(dplyr)
library(tidyr)
library(ggplot2)
library(DT)
library(reshape2)
options("getSymbols.warning4.0"=FALSE)
options("getSymbols.yahoo.warning"=FALSE)


####################################################################################################
##################### GETTING Stock Data, Exploring, Sending to AMPL ###############################
####################################################################################################

# Set tickers, start date, end date *the script is flexible (just change the tickers and dates
# to what you want and run the script up to reading in AMPL output section)

tickers = c("EFAX", "FNILX","USRT", "TSLA", "MTR")
startDate = "2020-01-01"
endDate = TODAY() # or whatever end date you want

# Get ticker prices
datalist = list()
for (i in tickers) {
  data = data.frame(getSymbols(i, from = startDate, to = endDate, env = NULL))
  datalist[[i]] = data 
}

# Set Adjusted Prices as a data frame
AdjPrices = data.frame(do.call(cbind, datalist))[,seq(6,length(tickers)*6,6)]
AdjPrices = tibble::rownames_to_column(AdjPrices, "Day")

# Get daily returns
n=nrow(AdjPrices)-1
datalist2 = list()
data2 = c()
for (j in 2:(length(tickers) + 1)) {
  for (t in 1:n) {
    data2[t] = (AdjPrices[,j][t + 1] - AdjPrices[,j][t]) / AdjPrices[,j][t]
    datalist2[[j]] = data2
  }
}

# Set returns as a data frame
returns = data.frame(do.call(cbind, datalist2))
returns = cbind(AdjPrices$Day[2:nrow(AdjPrices)], returns)
names(returns) = c("Day", c(tickers))

# Write data to a directory to be used in the AMPL .dat file (uncomment and write in your directory)
#write.table(returns, file = "~/Documents/DS808/FinalProject/AMPL/returns.txt", sep = "\t",
            #row.names = FALSE, col.names = TRUE)

# crete a table for std deviation and expected return of each stock
riskRetTab = data.frame()
for (i in names(returns[,2:(length(tickers)+1)])) {
  riskRetTab[i,1] = sd(returns[,i])
  riskRetTab[i,2] = mean(returns[,i])
}
riskRetTab = tibble::rownames_to_column(riskRetTab, "Stock")
colnames(riskRetTab) = c("Stock", "Std. Deviation", "Expected Return")
# see data table
datatable(riskRetTab)

# create a plot of daily stock returns
meltData = melt(returns, id.vars='Day')
ggplot(meltData, aes(Day, value, group = 1)) + 
  geom_line() + 
  facet_wrap(~variable)

####################################################################################################
################################ READING in AMPL Output and Plotting ###############################
####################################################################################################

# read in .txt files from AMPL that are outputted from .run and create one full report data frame
report = read.table("~/Documents/DS808/FinalProject/AMPL/report.txt", col.names = c("Variance", "ExpectedReturn"))
weights = read.table("~/Documents/DS808/FinalProject/AMPL/weights.txt", 
                     col.names = c(tickers))
full_report = cbind(report, "StdDev" = report$Variance^0.5, weights)

# Plot the Efficient Frontier of the AMPL output
ggplot(full_report, aes(StdDev,ExpectedReturn)) +
  geom_point(color = "steelblue") +
  labs(title = "Efficient Frontier", y = "Expected Return", x = "Portfolio Std. Deviation (Risk Level)") +
  theme_bw()

# This last part isn't really generalized, but you can follow a similar method for the stocks you have 
# in your portfolio
# Plot the Weights of each iteration from the AMPL output 
ggplot(full_report) + 
  geom_line(aes(StdDev, EFAX, color = "EFAX"), size = 1.5) + 
  geom_line(aes(StdDev, FNILX, color = "FNILX"), size = 1.5) + 
  geom_line(aes(StdDev, MTR, color = "MTR"), size = 1.5) + 
  geom_line(aes(StdDev, TSLA, color = "TSLA"), size = 1.5) + 
  geom_line(aes(StdDev, USRT, color = "USRT"), size = 1.5) +
  labs(title = "Asset Allocations over Varied Risk", y = "Weight", x = "Portfolio Std. Deviation (Risk Level)") +
  theme_bw() #+
#scale_x_continuous(breaks = seq(0.0003, 0.003, 0.0005))



