# =============================================================================
# stock_functions.R
# BDA400 - Assignment 2: Technical Analysis using R (Preliminary Stage)
# Author: Surinder Pal
#
# Functions to:
#   1. install / load the required packages
#   2. read portfolio.txt and import stock data with quantmod
#   3. calculate basic statistics (moving average, mean, mode, median, sd)
#   4. display the loaded data and the statistics
# =============================================================================

# -----------------------------------------------------------------------------
# setup_packages(): install any missing packages, then load them
# -----------------------------------------------------------------------------
setup_packages <- function(pkgs = c("quantmod", "TTR", "xts", "zoo")) {
  for (p in pkgs) {
    if (!requireNamespace(p, quietly = TRUE)) {
      install.packages(p)
    }
    library(p, character.only = TRUE)
  }
  invisible(TRUE)
}

# -----------------------------------------------------------------------------
# read_portfolio(): read stock symbols from a text file (one per line)
# -----------------------------------------------------------------------------
read_portfolio <- function(file = "portfolio.txt") {
  if (!file.exists(file)) stop("File not found: ", file)
  symbols <- trimws(readLines(file, warn = FALSE))
  symbols <- toupper(symbols[symbols != ""])   # drop blank lines
  unique(symbols)
}

# -----------------------------------------------------------------------------
# load_stock_data(): import data for every symbol in portfolio.txt
#   Returns a named list with one data frame per stock.
# -----------------------------------------------------------------------------
load_stock_data <- function(file = "portfolio.txt",
                            from = Sys.Date() - 365,
                            to   = Sys.Date()) {
  symbols    <- read_portfolio(file)
  stock_list <- list()

  for (sym in symbols) {
    message("Downloading ", sym, " ...")
    result <- tryCatch(
      getSymbols(sym, src = "yahoo", from = from, to = to, auto.assign = FALSE),
      error = function(e) {
        warning("Could not download ", sym, ": ", conditionMessage(e))
        NULL
      }
    )
    if (is.null(result)) next

    # Convert the xts object into a plain data frame with clean column names
    df <- data.frame(Date = index(result), coredata(result))
    colnames(df) <- c("Date", "Open", "High", "Low", "Close", "Volume", "Adjusted")
    stock_list[[sym]] <- df
  }

  message("Loaded ", length(stock_list), " of ", length(symbols), " symbols.")
  stock_list
}

# -----------------------------------------------------------------------------
# calc_mode(): most frequent value (R has no built-in statistical mode).
#   Prices are continuous, so they are rounded first (default: whole dollars).
# -----------------------------------------------------------------------------
calc_mode <- function(x, digits = 0) {
  x <- round(na.omit(x), digits)
  tab <- table(x)
  as.numeric(names(tab)[which.max(tab)])
}

# -----------------------------------------------------------------------------
# calculate_statistics(): statistics for ONE stock data frame
#   Adds 20- and 50-day simple moving averages to the data frame and
#   returns both the updated data and a one-row summary.
# -----------------------------------------------------------------------------
calculate_statistics <- function(df, column = "Close", ma_short = 20, ma_long = 50) {
  prices <- df[[column]]

  df[[paste0("SMA", ma_short)]] <- SMA(prices, n = ma_short)
  df[[paste0("SMA", ma_long)]]  <- SMA(prices, n = ma_long)

  summary_row <- data.frame(
    Mean      = mean(prices, na.rm = TRUE),
    Median    = median(prices, na.rm = TRUE),
    Mode      = calc_mode(prices),
    SD        = sd(prices, na.rm = TRUE),
    Min       = min(prices, na.rm = TRUE),
    Max       = max(prices, na.rm = TRUE),
    Latest    = tail(prices, 1),
    SMA_Short = tail(df[[paste0("SMA", ma_short)]], 1),
    SMA_Long  = tail(df[[paste0("SMA", ma_long)]], 1)
  )

  list(data = df, summary = summary_row)
}

# -----------------------------------------------------------------------------
# calculate_all_statistics(): run calculate_statistics() on every stock
#   Returns list(data = updated data frames, summary = one table for all stocks)
# -----------------------------------------------------------------------------
calculate_all_statistics <- function(stock_list, ...) {
  results <- lapply(stock_list, calculate_statistics, ...)

  summary_table <- do.call(rbind, lapply(names(results), function(sym) {
    cbind(Symbol = sym, results[[sym]]$summary)
  }))
  num_cols <- sapply(summary_table, is.numeric)
  summary_table[num_cols] <- round(summary_table[num_cols], 2)

  list(data = lapply(results, `[[`, "data"), summary = summary_table)
}

# =============================================================================
# DISPLAY UTILITIES
# =============================================================================

# display_stock(): print a header, the first/last rows and a quick summary
display_stock <- function(df, symbol, n = 5) {
  cat("\n==============================================\n")
  cat(" ", symbol, " | ", format(min(df$Date)), " to ", format(max(df$Date)),
      " | ", nrow(df), " trading days\n", sep = "")
  cat("==============================================\n")
  cat("\nFirst", n, "rows:\n");  print(head(df, n), row.names = FALSE)
  cat("\nLast",  n, "rows:\n");  print(tail(df, n), row.names = FALSE)
}

# display_all_stocks(): call display_stock() for every stock in the list
display_all_stocks <- function(stock_list, n = 5) {
  for (sym in names(stock_list)) display_stock(stock_list[[sym]], sym, n)
}

# display_quote(): Yahoo Finance-style "quote summary" for the latest day
display_quote <- function(df, symbol) {
  last <- tail(df, 1)
  prev <- df$Close[nrow(df) - 1]
  chg  <- last$Close - prev
  pct  <- chg / prev * 100
  cat(sprintf("\n%s  %.2f  %+.2f (%+.2f%%)   as of %s\n",
              symbol, last$Close, chg, pct, format(last$Date)))
  cat(sprintf("Open %.2f | High %.2f | Low %.2f | Volume %s\n",
              last$Open, last$High, last$Low,
              format(last$Volume, big.mark = ",")))
}

# plot_stock(): closing price with 20- and 50-day moving averages
plot_stock <- function(df, symbol) {
  plot(df$Date, df$Close, type = "l", lwd = 1.5, col = "black",
       main = paste(symbol, "- Closing Price with Moving Averages"),
       xlab = "Date", ylab = "Price (USD)")
  lines(df$Date, df$SMA20, col = "blue", lwd = 1.5)
  lines(df$Date, df$SMA50, col = "red",  lwd = 1.5)
  legend("topleft", legend = c("Close", "SMA 20", "SMA 50"),
         col = c("black", "blue", "red"), lwd = 1.5, bty = "n")
}

# plot_candles(): quantmod candlestick chart with volume and SMAs
plot_candles <- function(symbol, from = Sys.Date() - 180) {
  x <- getSymbols(symbol, src = "yahoo", from = from, auto.assign = FALSE)
  chartSeries(x, name = symbol, theme = chartTheme("white"),
              TA = "addVo();addSMA(20, col='blue');addSMA(50, col='red')")
}
