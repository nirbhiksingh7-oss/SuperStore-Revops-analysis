# Superstore Revenue Operations Analysis

## Business Context
Simulating the role of a Revenue Operations Analyst for a fictional 
retail company with $2.3M in annual sales across 4 territories. 
Goal: identify performance gaps, quota risks, pricing issues, and 
customer growth opportunities using SQL and Tableau.

## Tools Used
- SQL (SQLite via DB Browser for SQLite)
- Tableau Public (dashboard coming soon)

## Dataset
- Source: Sample Superstore Dataset (Kaggle)
- Size: 9,994 transactions | 4 regions | 3 customer segments | 17 product sub-categories
- Period: 2014 — 2017

## Business Questions Answered
1. Which territories are underperforming on revenue and margin?
2. Are sales territories hitting quota targets?
3. Which customer segments have the highest growth potential?
4. Who are the top 20% of customers driving revenue?
5. How are discounts impacting profitability?
6. Which customer segments have the highest ARPU?
7. What is the seasonal revenue pattern — when is the biggest risk?
8. Which product sub-categories are losing money?

## Key Findings

| # | Finding | Impact |
|---|---------|--------|
| 1 | Central region has lowest profit margin (7.92%) | Lowest efficiency territory |
| 2 | Central + South both missed quota (83.54% and 87.05%) | $166K+ in missed revenue |
| 3 | Discounts above 20% produce negative margins in ALL regions | Profit destruction |
| 4 | Central has 456 orders with 40%+ discounts at -135% margin | $52K in recoverable profit |
| 5 | Top 20% of customers drive 62.94% of total revenue | Classic Pareto confirmed |
| 6 | Home Office segment has highest ARPU ($1,245) and profit per customer ($164) | Best acquisition target |
| 7 | February is consistently the weakest month across all 4 years (avg 2.5% of annual revenue) | Q1 campaign opportunity |
| 8 | Tables sub-category loses $17,725 on $206K in revenue (-8.56% margin) | Reprice or discontinue |

## Recommendations

1. **Cap discounts at 20% company-wide** — recovers $52K in Central alone
2. **Prioritize Home Office customer acquisition** — highest profit per customer at $164
3. **Launch a February promotional campaign** — most consistent revenue gap across all years
4. **Reprice or discontinue Tables sub-category** — losing $17K despite $206K in sales
5. **Assign top account managers to Top 20% customers** — they drive 63% of all revenue

## SQL File
All 8 queries are available in [`SuperStore_RevOps Analysis.sql`](./SuperStore_RevOps%20Analysis.sql)

Queries are organized into 5 sections:
- Section 1: Regional & Territory Performance
- Section 2: Customer Segment Analysis
- Section 3: Pricing & Discount Analysis
- Section 4: ARPU & Revenue Trends
- Section 5: Product Profitability

## Tableau Dashboard
🔗 Live dashboard link — coming soon

## Author
**Nirbhik Singh**  
MBA, Management Science — Business Analytics | Ashland University  
https://www.linkedin.com/in/nirbhik-singh-734a8221a/?skipRedirect=true
