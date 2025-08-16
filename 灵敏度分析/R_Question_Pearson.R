library(readxl)
library(PerformanceAnalytics)
data_1 <- read_excel("data.xlsx")
chart.Correlation(data_1)