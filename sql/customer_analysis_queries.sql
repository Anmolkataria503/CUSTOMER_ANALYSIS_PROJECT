-- =====================================================
-- CUSTOMER ANALYSIS PROJECT
-- SQL ANALYSIS QUERIES
-- Database: customer_behaviour
-- =====================================================

-- Create and Select Database
CREATE DATABASE customer_behaviour;
USE customer_behaviour;

-- Verify Database and Tables
SHOW DATABASES;
SHOW TABLES;

-- View Sample Data
SELECT * FROM customer LIMIT 10;

-- Check Table Structure
DESCRIBE customer;

-- =====================================================
-- 1. Revenue by Gender
-- =====================================================

SELECT
    Gender,
    SUM(`Purchase Amount (USD)`) AS total_revenue
FROM customer
GROUP BY Gender
ORDER BY total_revenue DESC;

-- =====================================================
-- 2. Customers Using Discount Above Average Purchase
-- =====================================================

SELECT
    `Customer ID`,
    Gender,
    Age,
    `Item Purchased`,
    `Purchase Amount (USD)`
FROM customer
WHERE `Discount Applied` = 'Yes'
AND `Purchase Amount (USD)` >
(
    SELECT AVG(`Purchase Amount (USD)`)
    FROM customer
);

-- =====================================================
-- 3. Top 5 Highest Rated Products
-- =====================================================

SELECT
    `Item Purchased`,
    ROUND(AVG(`Review Rating`), 2) AS avg_review_rating
FROM customer
GROUP BY `Item Purchased`
ORDER BY avg_review_rating DESC
LIMIT 5;

-- =====================================================
-- 4. Products with Highest Discount Usage
-- =====================================================

SELECT
    `Item Purchased`,
    COUNT(*) AS total_purchases,
    SUM(CASE WHEN `Discount Applied` = 'Yes' THEN 1 ELSE 0 END) AS discounted_purchases,
    ROUND(
        100.0 * SUM(CASE WHEN `Discount Applied` = 'Yes' THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS discount_percentage
FROM customer
GROUP BY `Item Purchased`
ORDER BY discount_percentage DESC
LIMIT 5;

-- =====================================================
-- 5. Customer Segmentation
-- =====================================================

WITH customer_type AS (
    SELECT
        `Customer ID`,
        CASE
            WHEN `Previous Purchases` <= 5 THEN 'New'
            WHEN `Previous Purchases` <= 15 THEN 'Returning'
            ELSE 'Loyal'
        END AS customer_segment
    FROM customer
)

SELECT
    customer_segment,
    COUNT(*) AS customer_count
FROM customer_type
GROUP BY customer_segment
ORDER BY customer_count DESC;

-- =====================================================
-- 6. Top 3 Products in Each Category
-- =====================================================

WITH product_sales AS (
    SELECT
        Category,
        `Item Purchased`,
        COUNT(*) AS purchase_count,
        ROW_NUMBER() OVER (
            PARTITION BY Category
            ORDER BY COUNT(*) DESC
        ) AS rn
    FROM customer
    GROUP BY Category, `Item Purchased`
)

SELECT
    Category,
    `Item Purchased`,
    purchase_count
FROM product_sales
WHERE rn <= 3
ORDER BY Category, purchase_count DESC;

-- =====================================================
-- 7. Repeat Buyers vs Subscription Status
-- =====================================================

SELECT
    CASE
        WHEN `Previous Purchases` > 5 THEN 'Repeat Buyer'
        ELSE 'Non-Repeat Buyer'
    END AS customer_type,
    `Subscription Status`,
    COUNT(*) AS customer_count
FROM customer
GROUP BY
    CASE
        WHEN `Previous Purchases` > 5 THEN 'Repeat Buyer'
        ELSE 'Non-Repeat Buyer'
    END,
    `Subscription Status`
ORDER BY customer_type, customer_count DESC;

-- =====================================================
-- 8. Revenue Contribution by Age Group
-- =====================================================

SELECT
    CASE
        WHEN Age < 20 THEN 'Teen'
        WHEN Age BETWEEN 20 AND 35 THEN 'Young Adult'
        WHEN Age BETWEEN 36 AND 55 THEN 'Adult'
        ELSE 'Senior'
    END AS age_group,
    SUM(`Purchase Amount (USD)`) AS total_revenue,
    ROUND(
        100 * SUM(`Purchase Amount (USD)`) /
        (SELECT SUM(`Purchase Amount (USD)`) FROM customer),
        2
    ) AS revenue_contribution_pct
FROM customer
GROUP BY age_group
ORDER BY total_revenue DESC;

-- =====================================================
-- Environment Information
-- =====================================================

SELECT CURRENT_USER();
SELECT @@hostname;
SHOW DATABASES;
