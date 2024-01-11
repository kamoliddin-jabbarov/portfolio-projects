select * from SalesData;

--adding time_of_day column

alter table SalesData add time_of_day varchar(20);

update SalesData
set time_of_day = (
		case 
			when time between '00:00:00' and '12:00:00' then 'Morning'
			when time between '12:01:00' and '16:00:00' then 'Afternoon'
			else 'Evening'
		end
);

--day name

select 
	date,
	datename(weekday,date)
from SalesData;

alter table SalesData add day_name varchar(10);

update SalesData
set day_name = datename(weekday,date);

select * from SalesData;

-- month_name

select 
	date,
	DATENAME(month,date)
from SalesData;

alter table SalesData add month_name varchar(10);

update SalesData
set month_name = datename(month,date);

select * from SalesData;


-- Exploratory Data Analysis

--Generic--

-- How many unique cities does the data have?
select distinct(City) from SalesData;

select distinct(Branch) from SalesData;

--Product--

--How many unique product lines does the data have?
select distinct product_line from SalesData;

-- What is the most common payment method?
select 
	payment,
	COUNT(payment) count
from SalesData
group by payment
order by count desc;

-- What is the most selling product line?
select 
	Product_line,
	COUNT(Product_line) cnt
from SalesData
group by Product_line
order by cnt desc;

-- What is the real revenue by month?
select 
	month_name as month,
	sum(total) as total_revenue
from SalesData
group by month_name
order by total_revenue desc;

--What month had the largest COGS?
select 
	month_name as month,
	sum(cogs) as cogs
from SalesData
group by month_name
order by cogs desc;

--What product line had the largest revenue?
select 
	product_line,
	sum(total) as total
from SalesData
group by product_line
order by total desc;

--Which branch sold more products than average product sold?
select 
	branch,
	sum(quantity) as qty
from SalesData
group by branch
having sum(quantity) > (select avg(quantity) from SalesData)
order by qty desc;

Use
PortfolioProject
Go
select * from SalesData

-- Number of products sold by product line
select 
	product_line,
	sum(quantity) as summa
from SalesData
group by product_line
order by summa desc

-- Total revenue average by city and payment type

select payment,Naypyitaw,Yangon,Mandalay
from
(
	select payment,city,total
	from SalesData
) as Source
pivot
(
	avg(total)
	for city in(Naypyitaw,Yangon,Mandalay)
) as pivottable;

select * from SalesData

-- Average revenues are greater than the overall average income by time,day and month
​

with cte as 
(
	select 
		time_of_day,	
		day_name,
		month_name,
		avg(total) as total_avg
	from SalesData
	group by time_of_day,	
		day_name,
		month_name
)

select * from cte
where total_avg > (select avg(total) from SalesData)
	


