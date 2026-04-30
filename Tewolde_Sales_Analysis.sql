/* ==========================================================================
Naomi Tewolde 

Capstone_1

Data Aanlytics

Week 4 
/* ===========================================================================*/

USE sample_sales;


/*1) What is total revenue overall for sales in the assigned territory, 
plus the start date and end date that tell you what period the data covers?*/
/*===========================================================================*/ 

/*CONTEXT: Since I'm looking for the toatal revenue soley for 'Maryland' 
I have to pull from the management table, which includes my store ID and store sales for the total
by including the MIN Transaction date from store sales and the MAX transaction 
date. I also made sure to use the WHERE statments to filter out the Store_ID and management
so I could include all the information only from my assigned territory.*/

/*==============================================================================*/
-- ANSWER: SALES TERRITORY: Maryland, TOTAL REVENUE: 45370048.85, START DATE: 2022-01-01 END DATE: 2025-12-31


SELECT 'Maryland' AS Sales_Territory, -- Creating column for sales territory as Maryland for output
SUM(Sale_Amount) AS Total_Revenue, -- Adding Sales_Amount as Total Revenue column name 
MIN(Transaction_Date) AS Start_Date, -- MIN trans_date from ss, date time as start date column name
Max(Transaction_Date) AS End_Date -- MAX trans_date as end date in column name 
FROM Store_Sales -- pulling from this table
WHERE Store_ID = -- filtering storeID to look for all information matched with Maryland
(SELECT Store_ID FROM Management WHERE State = 'Maryland'); -- pulling from management table

-- 2) What is the month by month revenue breakdown for the sales territory?
/*==========================================================================*/

/*CONTEXT: This query seperates all non-Maryland state store transactions
It groups them by year and month with total revenue in that column order.
This gives a clear view of all the calculated monthly revenue.*/

/*=====================================================================*/ 

/*This select statement helps combine the sum of the revenue for 
each month and I created alias's to the Sales_Date from the 
store_sales(ss) table and transaction_date columns.*/ 

/*=======================================================================*/ 
SELECT 
	YEAR(Sale_Date) AS year, -- creates year column from the sale_date 
	MONTH(Sale_Date) AS month, -- creates month column from the sale_date
	SUM(revenue) AS total_revenue -- combining the sum of revenue as total_revnue column name
    
-- We have to pull the Store_Sales (alias being ss) table, which contains all the information about individual 
-- sales transactions, and use JOIN, which connects each sale to location(state), to add Store_Locations(alias sl), which
-- contains information about state, to combined the matching column "StoreID". The WHERE filters (sl.state) 'Maryland'
-- to exclude all non-Maryland sales. 
-- I have to use the subquery alias (all_sales). This helps make sure filtering happens before aggregation
-- Then using the GROUP BY function so that I can set the columns names as one row being Year and one Row being month 
-- and ORDER BY function to make the chart aligned and clear with support from the GROUP BY function. 

FROM 
(SELECT 
ss.Transaction_Date 
	AS Sale_Date,
ss.Sale_Amount 
	AS revenue
FROM store_sales ss -- pulling trans_date and sale_amount from ss table
JOIN store_locations sl -- joining with store_loc with the storeID column
	ON ss.Store_ID = sl.StoreId
WHERE sl.State = 'Maryland') -- filtering to find 

all_sales
GROUP BY Year, Month
ORDER BY Year, Month;


-- 3) Provide a comparison of total revenue for the specific sales territory and the region it belong to.  
-- ANSWER: LOCATION(STATE): Maryland, TOTAL REVENUE FROM SS: 11451615.09
-- ANSWER: LOCATION(REGION): Northeast, TOTAL REVENUE FROM SS: 24237526.98

-- CONTEXT: What this script is doing is separating Marylands total revenue and the regions 
-- total revenue. We have to aggregate total revenue for a clear, consise view of the comparision between 
-- both totals. 

-- I used the WITH clause which just creates a tempory named result just for this single
-- query so that the query is easier to read, which I set as md_region. I used the WHERE function
-- so that it could filter through region column FROM the management table for states that are listed
-- as 'Maryland' 

WITH md_region AS (
    SELECT Region
    FROM management
    WHERE State = 'Maryland'),
   
all_sales AS

 (SELECT
sl.State,
ss.Sale_Amount AS Revenue
FROM store_sales ss
JOIN store_locations sl
	ON ss.Store_ID = sl.StoreId)

SELECT
    Location,
    SUM(Revenue) AS Total_Revenue
    
 /* Maryland total revenue: This SELECT statement I made combines the all_sales subquery to 
filter revenue and location from 'Maryland' using the WHERE function. */
FROM (SELECT
'Maryland' AS 

Location,
	Revenue
FROM all_sales
WHERE State = 'Maryland'

    UNION ALL -- combining both queries, without removing duplicates since we're pulling information 
    -- from a specific state and the states from a specific region

/* Northeast region total: In this SELECT statement we have to find the total revenue from 
the Northeast region by pulling from the all_sales (s) subquery and the management (m) table 
and combining them from the shared information which is state, and not also forgeting that 
the all_sales query pulls information from total revenue and location. Also we created md_region 
to pull all the comparison states that align with the same region as Maryland, which would be Northeast */

SELECT
	m.Region AS Location,
	s.Revenue
FROM all_sales s
    JOIN management m
        ON s.State = m.State
    WHERE m.Region = (SELECT Region FROM md_region)
) combined
GROUP BY Location;
-- GROUP BY just helps create two clean rows of locations which would be Maryland and Northeast


-- 4) What is the number of transactions per month and average transaction size by product category
-- for the sales territory?

/*This SELECT statement is what I want my final out put to show. The question is asking for 
the year and month(and we're looking for the sales date) as well as category item names
column(which this will come from the inner query). 'Count(*)' helps count all the rows that 
exist in each group so for each row we'll see a transaction amount. AVG is just calculating
 average transaction size(which 'revenue' will be included in the subquery with an alias) */

SELECT YEAR(Sale_Date) AS Year, 
		MONTH (Sale_Date) AS Month,  
        Category,  
        COUNT(*) AS Number_of_Transactions, 
        AVG(Revenue) AS Avg_Transaction 

/* I created an inner query pulling all the information from
 store_sales (ss) table transaction dates and I renamed it as 
 sale_date to be more clear. I pulled the column ss.sale_amount 
 which shows the amount from each sale and renamed it as revenue. 
I also used c.category to pull all the category names. Then I joined 
store_sales and store_location through the same column name which was 
StoreID so that it can link the store sales and the location of those for
sales. I also created a script in the inner query JOINING products and store sales
so that each sale had a link to store sales and product. The last JOIN I did was
joining the inventory_categories to products using the categoryID so that there 
can be grouping and comparison */

FROM (SELECT 
ss.Transaction_Date 
	AS Sale_Date,     
ss.Sale_Amount
	AS Revenue,   
c.Category
	AS Category 
FROM store_sales AS ss
	JOIN store_locations AS sl
		ON ss.Store_ID = sl.StoreId 
	JOIN products AS p 
		ON ss.Prod_Num = p.ProdNum 
	JOIN inventory_categories AS c 
		ON p.Categoryid = c.Categoryid
WHERE sl.State = 'Maryland')
/* This WHERE function ensures that I'm filtering 
store location and state which would be Maryland. 
This keeps the sales in from Maryland */

AS all_sales   -- ends inner query
GROUP BY YEAR(Sale_Date),
		MONTH(Sale_Date),
        Category
        
ORDER BY Year,
		Month,
        Category;
/* GROUP BY function just shows how it summarizes the data and 
the ORDER BY function shows the order of the results */


-- 5) Can you provide a ranking of in-store sales performance by each store in the sales territory, or a
-- ranking of online sales performance by state within an online sales territory?

/*CONTEXT: I did a WITH function to create a temporary name to exist in this query create 
UNIONs. the SELECT statement is just defining the columns I want to include. sl.StoreID is 
pulling each store separately. m.Region shows the management region. I used the
SUM function AS Store revenue so it can show one total revenue per store.*/
WITH store_totals AS (
    SELECT
        sl.StoreId,
        m.Region,
        SUM(ss.Sale_Amount) AS Store_Revenue
    FROM store_sales ss -- JOINING ss and sl to StoreID to show transaction to location
    JOIN store_locations sl
        ON ss.Store_ID = sl.StoreId
    JOIN management m
        ON sl.State = m.State -- this JOIN shows which region each store belongs to from sl and m 
    WHERE m.Region = (
        
SELECT Region
        FROM management
        WHERE State = 'Maryland'
    ) 
    -- The WHERE function (m.region and SELECT region) separates region and Maryland and
	-- the subquery finds the region that Maryland belongs to
    GROUP BY sl.StoreId, m.Region
) 
/*OUTER select pulls information from my first WITH query */
SELECT
    StoreId,
    Region,
    Store_Revenue,
    RANK() OVER ( -- ranking store by revenue total
        ORDER BY Store_Revenue DESC
    ) AS Store_Rank
FROM store_totals -- pulls from the Store totals 
ORDER BY Store_Rank; -- sorts for row order


-- 6) What is your recommendation for where to focus sales attention in the next quarter?

/* From 2022 through 2025, the Northeast region, along with store IDs located in Maryland, have 
had consistent performance with average sale growth over time. Moving forward, 
the Northeast Region must shift focus on prioritizing low revenue stores and category matching to increase 
sale projection in the upcoming quarter by mixing high ranked category products as bundles with 
low average transactions categories for low volume stores to increase sales in low-ranked stores. 
The Northeast region’s top 10-15 ranked stores have a larger average transaction size from the top 3 
categories being Technology and Accessories, Apparel and Merchandise, and Books (General).  
The data shows progressive growth within top-ranked stores and low-ranked stores creating disproportionate 
sales revenue and average transactions. The goal is to increase sales with an action plan for low-ranked stores.
A alternitive plan would be as the region moves into the next quarter, mid-ranked stores should be soley targeted for growth initiatives 
while cutting low-ranked stores by merging them into mid-ranked stores. Either way, spending and investments on low-ranked 
categories should be reduced and bought in moderation as a part of the initiative of bundling product categories. */
