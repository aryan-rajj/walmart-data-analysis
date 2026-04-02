show databases;
drop database walmart_db;
create database walmart_db;

use walmart_db;
show tables;
use walmart;
select * from walmart where quantity is not null order by quantity desc limit 1;

-- identify the highest rated category for each branch displaying the branch category and avg rating 
select * from 
(
select 
	branch,
    category,
    avg(rating) as avg_rating,
    rank() over(partition by branch order by avg(rating) desc) as rank1
from 
	walmart
    group by branch,category
) as t1
where rank1=1;
-- identify the bussiest day for each branch based on no of transactions
select * from 
(select 
	branch,
	count(*) as no_of_transactions,
    dayname(date(date)) as day1,
    rank() over(partition by branch order by count(*) desc) as ranking
from walmart
group by branch,day1
) as table_2
where ranking=1;

-- calculate the total quantity of item sold per payment method . list payment_method and total_quantity
select 
	payment_method ,
    sum(quantity) as total_quantity
from walmart
group by payment_method 
order by total_quantity desc;

-- to find most used payment_method for each branch
-- display branch and prefered payment method
select branch,payment_method from
(
select
	branch,
    payment_method,
    count(*) as no_of_transactions,
    rank() over(partition by branch order by count(*) desc) as ranking
from walmart
group by branch,payment_method
) as table3
where ranking=1;

-- Q8: Categorize sales into Morning, Afternoon, and Evening shifts
SELECT
    branch,
    CASE 
        WHEN HOUR(TIME(time)) < 12 THEN 'Morning'
        WHEN HOUR(TIME(time)) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS shift,
    COUNT(*) AS num_invoices
FROM walmart
GROUP BY branch, shift
ORDER BY branch, num_invoices DESC;

-- Q9: Identify the 5 branches with the highest revenue decrease ratio from last year to current year (e.g., 2022 to 2023)
WITH revenue_2022 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = 2022
    GROUP BY branch
),
revenue_2023 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = 2023
    GROUP BY branch
)
SELECT 
    r2022.branch,
    r2022.revenue AS last_year_revenue,
    r2023.revenue AS current_year_revenue,
    ROUND(((r2022.revenue - r2023.revenue) / r2022.revenue) * 100, 2) AS revenue_decrease_ratio
FROM revenue_2022 AS r2022
JOIN revenue_2023 AS r2023 ON r2022.branch = r2023.branch
WHERE r2022.revenue > r2023.revenue
ORDER BY revenue_decrease_ratio DESC
LIMIT 5;
