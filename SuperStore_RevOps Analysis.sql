-- ============================================
-- SUPERSTORE REVENUE OPERATIONS ANALYSIS
-- Analyst: Nirbhik Singh
-- Dataset: Sample Superstore (Kaggle, 9,994 rows)
-- Tool: SQLite (DB Browser for SQLite)
-- Date: 2025
-- ============================================
-- BUSINESS CONTEXT:
-- Simulating the role of a Revenue Operations Analyst
-- for a fictional retail company. Goal: identify territory
-- performance gaps, quota risks, pricing issues, and
-- customer growth opportunities.
-- ============================================


-- ============================================
-- SECTION 1: REGIONAL & TERRITORY PERFORMANCE
-- ============================================

-- Query 1: Regional Revenue vs Profit vs Margin
-- Question: Which region generates the most revenue
-- and which is most profitable?
SELECT 
    Region,
    ROUND(SUM(Sales), 2) AS total_revenue,
    ROUND(SUM(Profit), 2) AS total_profit,
    ROUND(SUM(Profit) / SUM(Sales) * 100, 2) AS profit_margin_pct,
    COUNT(DISTINCT "Customer ID") AS total_customers,
    COUNT("Order ID") AS total_orders
FROM superstore
GROUP BY Region
ORDER BY total_revenue DESC;

-- Finding: Central region has lowest margin (7.92%)
-- despite being 3rd in revenue. West leads at 14.94%.


-- Query 2: Quota Attainment Simulation by Region
-- Question: Are territories hitting their revenue targets?
WITH regional_sales AS (
    SELECT 
        Region,
        ROUND(SUM(Sales), 2) AS total_revenue
    FROM superstore
    GROUP BY Region
),
quota AS (
    SELECT 'West' AS Region, 700000 AS quota_target
    UNION ALL SELECT 'East', 650000
    UNION ALL SELECT 'Central', 600000
    UNION ALL SELECT 'South', 450000
)
SELECT 
    r.Region,
    r.total_revenue,
    q.quota_target,
    ROUND(r.total_revenue / q.quota_target * 100, 2) AS quota_attainment_pct,
    CASE 
        WHEN r.total_revenue >= q.quota_target THEN 'Hit Quota'
        ELSE 'Missed Quota'
    END AS quota_status
FROM regional_sales r
JOIN quota q ON r.Region = q.Region
ORDER BY quota_attainment_pct DESC;

-- Finding: East (104.43%) and West (103.64%) hit quota.
-- Central (83.54%) and South (87.05%) missed.
-- Central is the only region with BOTH low margin AND missed quota.


-- ============================================
-- SECTION 2: CUSTOMER SEGMENT ANALYSIS
-- ============================================

-- Query 3: Customer Segment Revenue Trends Over Time
-- Question: Which segments are growing and which are at risk?
SELECT 
    Segment,
    substr("Order Date", -4) AS order_year,
    ROUND(SUM(Sales), 2) AS total_revenue,
    COUNT(DISTINCT "Customer ID") AS active_customers,
    ROUND(SUM(Sales) / COUNT(DISTINCT "Customer ID"), 2) AS revenue_per_customer
FROM superstore
GROUP BY Segment, order_year
ORDER BY Segment, order_year;

-- Finding: All segments growing. Home Office dipped in 2015
-- but recovered strongly. Corporate shows fastest ARPU growth.


-- Query 4: Top 20% Customer Pareto Analysis
-- Question: Who are the top customers driving revenue?
WITH customer_revenue AS (
    SELECT 
        "Customer ID",
        "Customer Name",
        Segment,
        Region,
        ROUND(SUM(Sales), 2) AS total_revenue,
        COUNT("Order ID") AS total_orders,
        ROUND(SUM(Profit), 2) AS total_profit
    FROM superstore
    GROUP BY "Customer ID", "Customer Name", Segment, Region
    ORDER BY total_revenue DESC
),
total AS (
    SELECT COUNT(*) AS total_customers,
           SUM(total_revenue) AS grand_total
    FROM customer_revenue
),
numbered AS (
    SELECT 
        c.*,
        t.total_customers,
        t.grand_total,
        ROW_NUMBER() OVER (ORDER BY total_revenue DESC) AS row_num
    FROM customer_revenue c, total t
)
SELECT 
    CASE 
        WHEN row_num <= total_customers * 0.20 THEN 'Top 20%'
        WHEN row_num <= total_customers * 0.40 THEN 'Next 20%'
        WHEN row_num <= total_customers * 0.60 THEN 'Middle 20%'
        WHEN row_num <= total_customers * 0.80 THEN 'Lower 20%'
        ELSE 'Bottom 20%'
    END AS customer_tier,
    COUNT(*) AS customer_count,
    ROUND(SUM(total_revenue), 2) AS tier_revenue,
    ROUND(SUM(total_revenue) * 100.0 / MAX(grand_total), 2) AS pct_of_total_revenue,
    ROUND(AVG(total_revenue), 2) AS avg_revenue_per_customer
FROM numbered
GROUP BY customer_tier
ORDER BY pct_of_total_revenue DESC;

-- Finding: Top 20% of customers drive 62.94% of revenue.
-- Bottom 20% contribute only 0.83%. Classic Pareto confirmed.
-- Top tier avg spend ($2,891) is 75x bottom tier ($38).


-- ============================================
-- SECTION 3: PRICING & DISCOUNT ANALYSIS
-- ============================================

-- Query 5: Discount vs Profit Impact by Region
-- Question: Are discounts destroying profitability?
WITH discount_buckets AS (
    SELECT 
        Region,
        "Customer ID",
        Sales,
        Profit,
        Discount,
        CASE 
            WHEN Discount = 0 THEN 'No Discount'
            WHEN Discount <= 0.10 THEN 'Low (1-10%)'
            WHEN Discount <= 0.20 THEN 'Medium (11-20%)'
            WHEN Discount <= 0.40 THEN 'High (21-40%)'
            ELSE 'Very High (40%+)'
        END AS discount_tier
    FROM superstore
)
SELECT 
    Region,
    discount_tier,
    COUNT(*) AS total_orders,
    ROUND(AVG(Discount) * 100, 2) AS avg_discount_pct,
    ROUND(SUM(Sales), 2) AS total_sales,
    ROUND(SUM(Profit), 2) AS total_profit,
    ROUND(SUM(Profit) / SUM(Sales) * 100, 2) AS profit_margin_pct
FROM discount_buckets
GROUP BY Region, discount_tier
ORDER BY Region, avg_discount_pct;

-- Finding: Discounts above 20% produce negative margins in ALL regions.
-- Central has 456 Very High discount orders at -135% margin.
-- Recommended fix: hard cap discounts at 20% company-wide.


-- ============================================
-- SECTION 4: ARPU & REVENUE TRENDS
-- ============================================

-- Query 6: ARPU Trends by Customer Segment
-- Question: How much revenue and profit per customer by segment?
SELECT 
    Segment,
    substr("Order Date", -4) AS order_year,
    COUNT(DISTINCT "Customer ID") AS active_customers,
    ROUND(SUM(Sales), 2) AS total_revenue,
    ROUND(SUM(Sales) / COUNT(DISTINCT "Customer ID"), 2) AS arpu,
    ROUND(SUM(Profit) / COUNT(DISTINCT "Customer ID"), 2) AS profit_per_customer
FROM superstore
GROUP BY Segment, order_year
ORDER BY Segment, order_year;

-- Finding: Home Office has highest 2017 ARPU ($1,245) and
-- profit per customer ($164) despite smallest customer base.
-- Highest ROI acquisition target.


-- Query 7: Monthly Revenue Trends — Q1 Drop Analysis
-- Question: When exactly does the business slow down seasonally?
WITH monthly_revenue AS (
    SELECT 
        substr("Order Date", -4) AS order_year,
        CASE
            WHEN substr("Order Date", 1, instr("Order Date", "/") - 1) = '1' THEN '01-Jan'
            WHEN substr("Order Date", 1, instr("Order Date", "/") - 1) = '2' THEN '02-Feb'
            WHEN substr("Order Date", 1, instr("Order Date", "/") - 1) = '3' THEN '03-Mar'
            WHEN substr("Order Date", 1, instr("Order Date", "/") - 1) = '4' THEN '04-Apr'
            WHEN substr("Order Date", 1, instr("Order Date", "/") - 1) = '5' THEN '05-May'
            WHEN substr("Order Date", 1, instr("Order Date", "/") - 1) = '6' THEN '06-Jun'
            WHEN substr("Order Date", 1, instr("Order Date", "/") - 1) = '7' THEN '07-Jul'
            WHEN substr("Order Date", 1, instr("Order Date", "/") - 1) = '8' THEN '08-Aug'
            WHEN substr("Order Date", 1, instr("Order Date", "/") - 1) = '9' THEN '09-Sep'
            WHEN substr("Order Date", 1, instr("Order Date", "/") - 1) = '10' THEN '10-Oct'
            WHEN substr("Order Date", 1, instr("Order Date", "/") - 1) = '11' THEN '11-Nov'
            ELSE '12-Dec'
        END AS month_label,
        ROUND(SUM(Sales), 2) AS monthly_revenue,
        COUNT("Order ID") AS total_orders
    FROM superstore
    GROUP BY order_year, month_label
)
SELECT 
    order_year,
    month_label,
    monthly_revenue,
    total_orders,
    ROUND(monthly_revenue * 100.0 / SUM(monthly_revenue) OVER (PARTITION BY order_year), 2) AS pct_of_annual_revenue
FROM monthly_revenue
ORDER BY order_year, month_label;

-- Finding: February is the weakest month every year without exception.
-- Averages 2.5% of annual revenue vs November's 15.4%.
-- Q4 drives 35-45% of annual revenue consistently.


-- ============================================
-- SECTION 5: PRODUCT PROFITABILITY
-- ============================================

-- Query 8: Product Category Profitability
-- Question: Which products are profitable and which are losing money?
SELECT 
    Category,
    "Sub-Category",
    COUNT("Order ID") AS total_orders,
    ROUND(SUM(Sales), 2) AS total_revenue,
    ROUND(SUM(Profit), 2) AS total_profit,
    ROUND(SUM(Profit) / SUM(Sales) * 100, 2) AS profit_margin_pct,
    ROUND(AVG(Discount) * 100, 2) AS avg_discount_pct
FROM superstore
GROUP BY Category, "Sub-Category"
ORDER BY profit_margin_pct DESC;

-- Finding: Tables sub-category loses $17,725 on $206K revenue (-8.56%).
-- Avg discount of 26.13% is above the 20% profit destruction threshold.
-- Labels (44.42%) and Paper (43.39%) are highest margin products.
-- Recommended fix: reprice or discontinue Tables sub-category.
