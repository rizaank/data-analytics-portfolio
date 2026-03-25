-- ============================================================
-- AdventureWorks Practice: Window Functions
-- RANK, DENSE_RANK, ROW_NUMBER, LAG, LEAD, SUM OVER, AVG OVER
-- Author: Rizaan
-- ============================================================


-- ------------------------------------------------------------
-- Q4: Salesperson revenue rank for 2013
-- Business Question: Each salesperson's name and total sales
-- revenue for 2013, ranked highest to lowest. Ties share a
-- rank and the next rank skips a number.
-- Pattern: Aggregation CTE → RANK() in outer query
-- ------------------------------------------------------------
WITH SalesRevenue AS (
    SELECT 
        c.FirstName,
        c.LastName,
        SUM(a.TotalDue) AS TotalRevenue
    FROM Sales.SalesOrderHeader a
    JOIN Sales.SalesPerson b ON b.BusinessEntityID = a.SalesPersonID
    JOIN Person.Person c ON c.BusinessEntityID = b.BusinessEntityID
    WHERE YEAR(a.OrderDate) = 2013
    GROUP BY c.FirstName, c.LastName
)
SELECT
    FirstName,
    LastName,
    TotalRevenue,
    RANK() OVER (ORDER BY TotalRevenue DESC) AS SalesRank
FROM SalesRevenue
ORDER BY TotalRevenue DESC;


-- ------------------------------------------------------------
-- Q5: Product total quantity sold with running total
-- Business Question: Every product ever ordered, total qty
-- sold, and a running total of qty sold ordered descending.
-- Pattern: Aggregation CTE → SUM OVER running total
-- ------------------------------------------------------------
WITH TotalProdSold AS (
    SELECT
        b.Name,
        SUM(a.OrderQty) AS TotalQtySold
    FROM Sales.SalesOrderDetail a
    JOIN Production.Product b ON b.ProductID = a.ProductID
    GROUP BY b.Name
)
SELECT 
    Name,
    TotalQtySold,
    SUM(TotalQtySold) OVER (
        ORDER BY TotalQtySold DESC
    ) AS RunningTotalQtySold
FROM TotalProdSold;


-- ------------------------------------------------------------
-- Q6: Product list price vs subcategory max price
-- Business Question: Each product and its list price, plus the
-- highest list price in its subcategory for comparison.
-- Pattern: JOIN CTE → MAX() OVER PARTITION BY
-- Key concept: PARTITION BY keeps all rows (vs GROUP BY which
-- collapses them)
-- ------------------------------------------------------------
WITH ProdListPrice AS (
    SELECT 
        b.Name AS ProductSubcategory,
        a.Name AS Product, 
        a.ListPrice AS ProdListPrice
    FROM Production.Product a 
    JOIN Production.ProductSubcategory b 
        ON b.ProductSubcategoryID = a.ProductSubcategoryID
)
SELECT 
    *,
    MAX(ProdListPrice) OVER (
        PARTITION BY ProductSubcategory
    ) AS MaxSubListPrice
FROM ProdListPrice
ORDER BY ProductSubcategory;


-- ------------------------------------------------------------
-- Q7: Salesperson year-over-year revenue with LAG
-- Business Question: Each salesperson's revenue by year, their
-- prior year revenue, and the dollar difference.
-- Pattern: Aggregation CTE → LAG CTE → CASE WHEN CTE
-- Key concept: LAG looks back one row within a partition
-- ------------------------------------------------------------
WITH TotalRevenueByYr AS (
    SELECT
        b.FirstName,
        b.LastName,
        YEAR(a.OrderDate) AS Year,
        SUM(a.TotalDue) AS TotalRevenue
    FROM Sales.SalesOrderHeader a
    JOIN Person.Person b ON b.BusinessEntityID = a.SalesPersonID
    GROUP BY b.FirstName, b.LastName, YEAR(a.OrderDate)
),
WithLag AS (
    SELECT
        FirstName,
        LastName,
        Year,
        TotalRevenue AS CurrYrRev,
        LAG(TotalRevenue, 1) OVER (
            PARTITION BY FirstName, LastName 
            ORDER BY Year
        ) AS PriorYrRev
    FROM TotalRevenueByYr
)
SELECT
    FirstName,
    LastName,
    Year,
    CurrYrRev,
    PriorYrRev,
    CASE
        WHEN PriorYrRev IS NULL THEN 0
        ELSE CurrYrRev - PriorYrRev
    END AS DiffInRev
FROM WithLag;


-- ------------------------------------------------------------
-- Q9: Product ranking using DENSE_RANK
-- Business Question: Rank all products by total quantity sold.
-- Ties share a rank and the next rank does NOT skip.
-- Key concept: DENSE_RANK vs RANK — DENSE_RANK never skips
-- ------------------------------------------------------------
WITH ProdQtySold AS (
    SELECT 
        b.Name AS ProdName,
        SUM(a.OrderQty) AS TotalQtySold
    FROM Sales.SalesOrderDetail a 
    JOIN Production.Product b ON b.ProductID = a.ProductID
    GROUP BY b.Name
)
SELECT
    ProdName, 
    TotalQtySold, 
    DENSE_RANK() OVER (
        ORDER BY TotalQtySold DESC
    ) AS DenseRank
FROM ProdQtySold;


-- ------------------------------------------------------------
-- Q10: Salesperson revenue with LEAD (following year)
-- Business Question: Each salesperson's revenue by year plus
-- their revenue the following year. Show 0 if no following yr.
-- Key concept: LEAD looks forward, LAG looks backward
-- ------------------------------------------------------------
WITH TotalRevenueByYr AS (
    SELECT 
        b.FirstName, 
        b.LastName, 
        YEAR(a.OrderDate) AS Year, 
        SUM(a.TotalDue) AS TotalRevCurrYr
    FROM Sales.SalesOrderHeader a
    JOIN Person.Person b ON b.BusinessEntityID = a.SalesPersonID
    GROUP BY b.FirstName, b.LastName, YEAR(a.OrderDate)
),
WithLeadYr AS (
    SELECT
        FirstName, 
        LastName, 
        Year, 
        TotalRevCurrYr, 
        LEAD(TotalRevCurrYr, 1) OVER (
            PARTITION BY FirstName, LastName 
            ORDER BY Year
        ) AS TotalRevFollowingYr
    FROM TotalRevenueByYr
)
SELECT 
    FirstName, 
    LastName, 
    Year, 
    TotalRevCurrYr, 
    CASE
        WHEN TotalRevFollowingYr IS NULL THEN 0
        ELSE TotalRevFollowingYr
    END AS TotalRevFollowingYr
FROM WithLeadYr;
