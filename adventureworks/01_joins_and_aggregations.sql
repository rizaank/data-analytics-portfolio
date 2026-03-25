-- ============================================================
-- AdventureWorks Practice: Joins and Aggregations
-- Author: Rizaan
-- ============================================================


-- ------------------------------------------------------------
-- Q1: Customers with more than 3 orders
-- Business Question: List every customer's full name and total
-- number of orders placed. Only show customers with more than
-- 3 orders, sorted by most orders first.
-- ------------------------------------------------------------
SELECT 
    b.FirstName, 
    b.LastName, 
    COUNT(c.SalesOrderID) AS TotalOrderCount
FROM Sales.Customer a
JOIN Person.Person b ON b.BusinessEntityID = a.PersonID
JOIN Sales.SalesOrderHeader c ON c.CustomerID = a.CustomerID
GROUP BY b.FirstName, b.LastName
HAVING COUNT(c.SalesOrderID) > 3
ORDER BY TotalOrderCount DESC;


-- ------------------------------------------------------------
-- Q2: Product subcategories with over $500K in revenue
-- Business Question: Which product subcategories generated over
-- $500,000 in total sales revenue? Show subcategory name and
-- total revenue, highest first.
-- ------------------------------------------------------------
SELECT 
    c.Name AS SubcategoryName,
    SUM(a.LineTotal) AS TotalRevenue
FROM Sales.SalesOrderDetail a 
JOIN Production.Product b ON b.ProductID = a.ProductID
JOIN Production.ProductSubcategory c 
    ON c.ProductSubcategoryID = b.ProductSubcategoryID
GROUP BY c.Name
HAVING SUM(a.LineTotal) > 500000
ORDER BY TotalRevenue DESC;
