# TechnicalAnalysis

Stock technical analysis in R for **BDA400 – Data Science Tools and Techniques**.
Author: **Surinder Pal**

This repository holds all three stages of the course project. Each assignment has its own folder.

## Repository Structure

```text
TechnicalAnalysis/
├── Assignment2/                         # Stage 1: setup, data import, basic statistics
│   ├── portfolio.txt                    # Stock symbols, one per line
│   ├── stock_functions.R                # load_stock_data(), calculate_statistics(), display utilities
│   ├── technical_analysis.Rmd           # Full walkthrough with tables and charts
│   ├── run_analysis.R                   # Runs everything from the console
│   └── SurinderPal_BDA400_A02_Report.docx
└── README.md
```

## Requirements

- R 4.2+ and RStudio
- Packages: `quantmod`, `TTR`, `xts`, `zoo`, `knitr`, `rmarkdown`

```r
install.packages(c("quantmod", "TTR", "xts", "zoo", "knitr", "rmarkdown"))
```

## Quick Start

1. Open `Assignment2/technical_analysis.Rmd` in RStudio.
2. Click **Knit**.

Or run `Assignment2/run_analysis.R` after setting the working directory to the `Assignment2` folder.

## Portfolio

AAPL, MSFT, AMZN, GOOGL, TSLA, SHOP

Data source: Yahoo Finance via `quantmod`.
