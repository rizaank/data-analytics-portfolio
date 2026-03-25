-- ============================================================
-- AdventureWorks Practice: CASE WHEN
-- Author: Rizaan
-- ============================================================


-- ------------------------------------------------------------
-- Q3: Product price tier labeling
-- Business Question: Show each product's name, list price, and
-- a label classifying it as Budget / Mid-Range / Premium.
-- ------------------------------------------------------------
SELECT 
    Name,
    ListPrice,
    CASE
        WHEN ListPrice < 100 THEN 'Budget'
        WHEN ListPrice BETWEEN 100 AND 1000 THEN 'Mid-Range'
        WHEN ListPrice > 1000 THEN 'Premium'
        ELSE 'No Price Listed'
    END AS PriceTier
FROM Production.Product;
