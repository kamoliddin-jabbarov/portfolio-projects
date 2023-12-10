--Option 1 
--I used only the payments table to calculate the payments
--a
select a.customerName,sum(b.amount)
from customers a
inner join payments b
on a.customerNumber = b.customerNumber
group by a.customerName
order by a.customerName;

--b
select a.customerName,date_part('year',b.paymentDate) as year,date_part('week',b.paymentDate) as week,count(*) as weekly_frequency
from customers a
inner join payments b
on a.customerNumber = b.customerNumber
group by a.customerName,year,week
order by a.customerName,year,week;

--c
select paymentDate,sum(amount)
from payments
group by paymentDate
order by paymentDate;

--Option 2

--a

--With Subqueries
select a.customerName,sum(d.MSRP)
from customers a,orders b,orderdetails c,products d
where a.customerNumber = b.customerNumber
and b.orderNumber = c.orderNumber
and c.productCode = d.productCode
group by a.customerName
order by a.customerName;

--With Joins
select a.customerName,sum(d.MSRP)
from customers a
inner join orders b
on a.customerNumber = b.customerNumber
inner join orderdetails c
on b.orderNumber = c.orderNumber
inner join products d
on c.productCode = d.productCode
group by a.customerName
order by a.customerName;

--b

--With Subqueries
select a.customerName,date_part('year',b.orderDate) as year,
date_part('week',b.orderDate) as week,count(*) as weekly_frequency
from customers a,orders b
where a.customerNumber = b.customerNumber
group by a.customerName,year,week
order by a.customerName,year,week

--With Joins
select a.customerName,date_part('year',b.orderDate) as year,
date_part('week',b.orderDate) as week,count(*) as weekly_frequency
from customers a
inner join orders b
on a.customerNumber = b.customerNumber
group by a.customerName,year,week
order by a.customerName,year,week

--c

--With Subqueries
select a.orderdate,sum(c.MSRP)
from  orders a,orderdetails b,products c
where a.orderNumber = b.orderNumber
and b.productCode = c.productCode
group by a.orderdate
order by a.orderdate;


--With Joins
select a.orderdate,sum(c.MSRP)
from orders a
inner join orderdetails b
on a.orderNumber = b.orderNumber
inner join products c
on b.productCode = c.productCode
group by a.orderdate
order by a.orderdate;



with customers_cte as (
	select 
	customerNumber,
	(case
	 when creditlimit > 40000 then 'min'
	 else 'max'
	 end) as level
	from customers
)

select * from customers_cte
