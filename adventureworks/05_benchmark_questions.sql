-- ============================================================
-- AdventureWorks Benchmark Questions — No Hints
-- These were completed without pattern hints or table guidance
-- to simulate real interview conditions
-- Author: Rizaan
-- ============================================================


-- ------------------------------------------------------------
-- Benchmark Q1: Sales team performance review
-- Business Question: Each salesperson's full name, total number
-- of orders, total revenue, and average order value. Only
-- salespeople with more than 30 orders. Ranked by revenue.
-- Lesson learned: COUNT(DISTINCT SalesOrderID) for order count
-- vs SUM(OrderQty) for item count — these are different things
-- ------------------------------------------------------------
WITH PerfReview AS (
    SELECT 
        c.FirstName, 
        c.LastName, 
        COUNT(DISTINCT b.SalesOrderID) AS TotalOrders, 
        SUM(b.TotalDue) AS TotalRevenue, 
        SUM(b.TotalDue) / COUNT(DISTINCT b.SalesOrderID) AS AvgOrderValue
    FROM Sales.SalesOrderDetail a
    JOIN Sales.SalesOrderHeader b ON b.SalesOrderID = a.SalesOrderID
    JOIN Person.Person c ON c.BusinessEntityID = b.SalesPersonID
    GROUP BY c.FirstName, c.LastName
    HAVING COUNT(DISTINCT b.SalesOrderID) > 30
)
SELECT 
    *, 
    RANK() OVER (ORDER BY TotalRevenue DESC) AS RankByTotalRev
FROM PerfReview;


-- ------------------------------------------------------------
-- Benchmark Q2: Underperforming products vs category average
-- Business Question: Products below their category average
-- revenue. Show product, category, total revenue, category
-- average, and the gap. Sort by biggest gap first.
-- Lesson learned: AVG() OVER PARTITION BY with no ORDER BY
-- inside OVER — adding ORDER BY changes it to a running avg
-- ------------------------------------------------------------
WITH ProdTotalRev AS (
    SELECT 
        a.Name AS ProductName, 
        c.Name AS CategoryName,
        SUM(e.TotalDue) AS TotalProdRev
    FROM Production.Product a
    JOIN Production.ProductSubCategory b 
        ON b.ProductSubCategoryID = a.ProductSubcategoryID
    JOIN Production.ProductCategory c 
        ON c.ProductCategoryID = b.ProductCategoryID
    JOIN Sales.SalesOrderDetail d ON d.ProductID = a.ProductID
    JOIN Sales.SalesOrderHeader e ON e.SalesOrderID = d.SalesOrderID
    GROUP BY a.Name, c.Name
), 
WithAvgCatRev AS (
    SELECT 
        *,
        AVG(TotalProdRev) OVER (
            PARTITION BY CategoryName
        ) AS AvgCatRev
    FROM ProdTotalRev
),
WithDiff AS (
    SELECT 
        *,
        (TotalProdRev - AvgCatRev) AS RevGap
    FROM WithAvgCatRev
)
SELECT *
FROM WithDiff
WHERE RevGap < 0
ORDER BY RevGap ASC;


-- ------------------------------------------------------------
-- Benchmark Q3: Year-end salesperson performance report
-- Business Question: Salesperson revenue by year, prior year
-- comparison in dollars and percentage, 0 if first year.
-- Ranked within each year using DENSE_RANK. 2012 onwards only.
-- Lesson learned: NULLIF prevents divide by zero cleanly.
-- CAST to DECIMAL prevents integer division truncation.
-- ------------------------------------------------------------
WITH SalesByYear AS (
    SELECT 
        b.FirstName, 
        b.LastName, 
        YEAR(a.OrderDate) AS Year, 
        SUM(a.TotalDue) AS TotalRev
    FROM Sales.SalesOrderHeader a
    JOIN Person.Person b ON b.BusinessEntityID = a.SalesPersonID
    GROUP BY b.FirstName, b.LastName, YEAR(a.OrderDate)
),
WithLag AS (
    SELECT 
        *,
        LAG(TotalRev, 1) OVER (
            PARTITION BY FirstName, LastName 
            ORDER BY Year
        ) AS PriorYearRev
    FROM SalesByYear
),
WithDiff AS (
    SELECT 
        *,
        (TotalRev - PriorYearRev) AS RevDiff,
        ((TotalRev - PriorYearRev) / 
            NULLIF(CAST(PriorYearRev AS DECIMAL(18,2)), 0)
        ) * 100 AS PctChange
    FROM WithLag
    WHERE Year >= 2012
)
SELECT 
    FirstName,
    LastName,
    Year,
    TotalRev,
    PriorYearRev,
    CASE WHEN PriorYearRev IS NULL THEN 0 ELSE RevDiff END AS RevDiff,
    CASE WHEN PriorYearRev IS NULL THEN 0 ELSE PctChange END AS PctChange,
    DENSE_RANK() OVER (
        PARTITION BY Year 
        ORDER BY TotalRev DESC
    ) AS RankByYear
FROM WithDiff;
