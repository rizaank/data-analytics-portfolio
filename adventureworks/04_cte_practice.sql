-- ============================================================
-- AdventureWorks Practice: CTEs and Deduplication
-- Author: Rizaan
-- ============================================================


-- ------------------------------------------------------------
-- Q8: Top 3 products by quantity sold per category
-- Business Question: Only the top 3 best selling products by
-- total quantity within each product category.
-- Pattern: Aggregation CTE → ROW_NUMBER CTE → filter WHERE
-- Key concept: Cannot filter on window function in same SELECT
-- where it is defined — must wrap in CTE first
-- ------------------------------------------------------------
WITH ProdQtySold AS (
    SELECT 
        d.Name AS ProductCategory,
        b.Name AS ProductName,
        SUM(a.OrderQty) AS TotalQtySold
    FROM Sales.SalesOrderDetail a
    JOIN Production.Product b ON b.ProductID = a.ProductID
    JOIN Production.ProductSubcategory c 
        ON c.ProductSubcategoryID = b.ProductSubcategoryID
    JOIN Production.ProductCategory d 
        ON d.ProductCategoryID = c.ProductCategoryID
    GROUP BY b.Name, d.Name
),
WithRowNum AS (
    SELECT 
        ProductCategory, 
        ProductName, 
        TotalQtySold, 
        ROW_NUMBER() OVER (
            PARTITION BY ProductCategory 
            ORDER BY TotalQtySold DESC
        ) AS RowRank
    FROM ProdQtySold
)
SELECT 
    ProductCategory, 
    ProductName, 
    TotalQtySold,
    RowRank
FROM WithRowNum
WHERE RowRank <= 3
ORDER BY ProductCategory, TotalQtySold DESC;


-- ------------------------------------------------------------
-- Q11: Deduplication using ROW_NUMBER
-- Business Question: Return a clean unique product list. Where
-- a product name appears more than once, keep only the row
-- with the lowest ProductID.
-- Pattern: ROW_NUMBER PARTITION BY duplicate column → filter
-- WHERE RowNum = 1
-- Key concept: PARTITION BY the column that defines the dupe
-- ------------------------------------------------------------
WITH ProdListDup AS (
    SELECT 
        ProductID,
        Name,
        ListPrice, 
        Color, 
        ROW_NUMBER() OVER (
            PARTITION BY Name 
            ORDER BY ProductID ASC
        ) AS RowNum
    FROM Production.Product
)
SELECT 
    ProductID,
    Name,
    ListPrice,
    Color
FROM ProdListDup
WHERE RowNum = 1;
