# =============================================================================
# run_analysis.R
# BDA400 - Assignment 2 | Author: Surinder Pal
# Runs the whole preliminary analysis from the console.
# Set the working directory to the Assignment2 folder first:
#   Session > Set Working Directory > To Source File Location
# =============================================================================

source("stock_functions.R")

# 1. Packages
setup_packages()

# 2. Load data for every symbol in portfolio.txt
stocks <- load_stock_data("portfolio.txt")

# 3. Display the loaded data
display_all_stocks(stocks)
for (sym in names(stocks)) display_quote(stocks[[sym]], sym)

# 4. Statistics
results <- calculate_all_statistics(stocks)
print(results$summary, row.names = FALSE)

# 5. Charts
for (sym in names(results$data)) plot_stock(results$data[[sym]], sym)
plot_candles("AAPL")
