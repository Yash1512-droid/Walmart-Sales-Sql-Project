select * from walmart,select * from stores


--Find the total weekly sales for each store.

select sum(weekly_sales),store
from walmart
group by store;

--Find the average unemployment rate for each store.
select avg(unemployment),store
from walmart
group by store;

--Retrieve the average weekly sales for each store only during holiday weeks (Holiday_Flag = 1).

select store,avg(weekly_sales)
from walmart 
where holiday_flag = 1
group by store;

--Retrieve the top 5 stores with the highest total weekly sales.

select store,sum(weekly_sales)as highest_sales
from walmart
group by store
order by highest_sales desc
limit 5;

--Find the total weekly sales for each month of the year 2010.
SELECT 
    EXTRACT(YEAR FROM Date) AS Year,
    EXTRACT(MONTH FROM Date) AS Month,
    SUM(Weekly_Sales) AS Total_Weekly_Sales
FROM walmart
WHERE EXTRACT(YEAR FROM Date) = 2010
GROUP BY EXTRACT(YEAR FROM Date), EXTRACT(MONTH FROM Date)
ORDER BY Month;

--find the total weekly sales for each region by joining walmart with stores.

select region,sum(weekly_sales)as total_sales
from stores s
join walmart w
on s.store = w.store
group by region
order by total_sales desc;

--Find the average fuel price for each region
select region,avg(fuel_price)as avg_price
from stores s
join walmart w
on s.store = w.store
group by region
order by avg_price desc;

--Find the average unemployment rate for each region only during holiday weeks

select region,avg(unemployment)
from stores s
join walmart w
on s.store = w.store
where holiday_flag = 1
group by region;

--Find the average weekly sales per month for each store.

select
	store,
	extract(month from date)as month,
	avg(weekly_sales)
from walmart	
group by store,extract(month from date)
order by store,month;


--Find the top 3 stores with the highest average temperature recorded.


with ranked as(
	select store, 
		AVG(temperature) AS avg_temperature,
		rank() over(ORDER BY AVG(temperature) DESC) AS rn
		from walmart
	group by store
)
	select store,avg_temperature
	from ranked
	where rn <= 3;


--Find the top 5 stores with the highest total weekly sales during holiday weeks

with ranked as(
	select store,
		sum(weekly_sales)as total_sales,
		rank() over(order by sum(weekly_sales) DESC)as rn
		from walmart
	where holiday_flag = 1
	group by store
	LIMIT 5
)
	select store,total_sales
	from ranked
	where rn <=5;

	
--Find the week with the highest single-week sales for each store	

with ranked as(
	select
		store,
		weekly_sales,
		date,
		rank()over(partition by store order by weekly_sales desc)as rn
		from walmart
)
	select store,weekly_sales,date
	from ranked
	where rn = 1;


-- For each store, find the top 3 weeks with the highest weekly sales.	

with ranked as(
	select
		store,
		weekly_sales,
		date,
		rank()over(partition by store order by weekly_sales desc)as rn
		from walmart
)
	select store,weekly_sales,date
	from ranked
	where rn <=3;


--For each store, calculate the running total of weekly sales ordered by date.

WITH sales_running AS (
    SELECT 
        store,
        date,
        weekly_sales,
        SUM(weekly_sales) OVER (PARTITION BY store ORDER BY date) AS running_total_sales
    FROM walmart
)
SELECT store, date, weekly_sales, running_total_sales
FROM sales_running
ORDER BY store, date;


--For each store, calculate the week-over-week change in sales.

select 
	store,
	weekly_sales,
	date,
	lag(weekly_sales)over(partition by store order by date)as previous_week_sales,
	weekly_sales-lag(weekly_sales)over(partition by store order by date)as sales_difference
from walmart
order by date,store;
	

--For each store, calculate the next week’s sales and the expected change

select
	store,
	weekly_sales,
	date,
	lead(weekly_sales)over(partition by store order by date)as next_week_sales,
	weekly_sales-lead(weekly_sales)over(partition by store order by date)as sales_differnce
from walmart	
order by date,store;


--Show Previous and next week per store

select
	store,
	date,
	weekly_sales,
	lag(weekly_sales)over(partition by store order by date)as previous_week_sales,
	lead(weekly_sales)over(partition by store order by date)as next_week_sales
from walmart
order by store,date;


--For each store, calculate the 7-day moving average of weekly_sales ordered by date

select
	store,
	weekly_Sales,
	date,
	avg(weekly_sales)over(partition by store order by date rows between 6 preceding and current row )as moving_average 
from walmart
order by store,date;
	
	
--For each store, find the top 2 weeks with the biggest sales drop compared to the previous week..--we use rank because we want top 2

with ranked as(
	select
		store,
		weekly_sales,
		date,
		lag(weekly_sales)over(partition by store order by date)previous_sale,
		weekly_sales-lag(weekly_sales)over(partition by store order by date)as sale_difference
from walmart
)
	select store,weekly_sales,date,sale_difference,
	rank()over(partition by store order by sales_difference asc)as rn
from ranked
where rn <=2;	








	


