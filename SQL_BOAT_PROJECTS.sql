create database Boat_2;
use Boat_2;

select * from Boat_customer;
select * from order_boat;
select * from order_detail;
select * from products;
select * from  returns;

#Boat cleaning
#boat_customer

select * from boat_customer;
describe boat_customer;


alter table boat_customer 
modify column name varchar(100);


alter table boat_customer 
modify column last_name varchar(100);

alter table boat_customer 
modify column email  varchar(100);



alter table boat_customer 
modify column gender char (1);

alter table boat_customer 
modify column phone  varchar(20);

alter table boat_customer 
modify column city  varchar(100);

alter table boat_customer 
modify column state varchar(100);

alter table boat_customer
modify column registration_date date;

set sql_safe_updates=0;

UPDATE boat_customer
SET registration_date =
CASE
    WHEN registration_date LIKE '%/%'
        THEN STR_TO_DATE(registration_date, '%d/%m/%Y')
    WHEN registration_date LIKE '%-%'
        THEN STR_TO_DATE(registration_date, '%d-%m-%Y')
END
WHERE registration_date IS NOT NULL;    


#order_boat...
select * from order_boat;
describe order_boat;

UPDATE  order_boat
SET  order_date =
CASE
    WHEN  order_date LIKE '%/%'
        THEN STR_TO_DATE( order_date, '%d/%m/%Y')
    WHEN  order_date LIKE '%-%'
        THEN STR_TO_DATE( order_date, '%d-%m-%Y')
END
WHERE  order_date IS NOT NULL;   

alter table order_boat
modify column order_date date;


#shipped date tik ke lie 

UPDATE  order_boat
SET  shipped_date=
CASE
    WHEN  shipped_date LIKE '%/%'
        THEN STR_TO_DATE( shipped_date, '%d/%m/%Y')
    WHEN  shipped_date LIKE '%-%'
        THEN STR_TO_DATE( shipped_date, '%d-%m-%Y')
END
WHERE  shipped_date IS NOT NULL;  


alter table order_boat
modify column shipped_date date;

#delivery date tik karne k lie 

UPDATE  order_boat
SET  delivery_date=
CASE
    WHEN  delivery_date LIKE '%/%'
        THEN STR_TO_DATE( delivery_date, '%d/%m/%Y')
    WHEN  delivery_date LIKE '%-%'
        THEN STR_TO_DATE( delivery_date, '%d-%m-%Y')
END
WHERE  delivery_date IS NOT NULL;


alter table order_boat
modify column delivery_date date;

alter table order_boat
modify column payment_method varchar(50),
modify column shipping_address varchar(100),
modify column order_status varchar(50),
modify column order_channel varchar(50);

#order_detail
select * from order_detail;
describe order_detail;

alter table order_detail
modify column discount_percent float;

#products
select * from products;
describe products;

alter table products
modify column product_name varchar(250),
modify column category varchar(50),
modify column rating  float,
modify column color varchar(50),
modify column model_number varchar(50),
modify column Review varchar(50),
modify column Review_tag varchar(50);


#returns
select * from returns;
describe returns;

UPDATE  returns
SET  return_date =
CASE
    WHEN  return_date LIKE '%/%'
        THEN STR_TO_DATE( return_date, '%d/%m/%Y')
    WHEN  return_date LIKE '%-%'
        THEN STR_TO_DATE( return_date, '%d-%m-%Y')
END
WHERE  return_date IS NOT NULL;

alter table returns
modify column return_date date;

alter table returns
modify column reason varchar(250),
modify column refund_status varchar(50);

#2.ANALYIS DATE 
#1.KPI 'S' 
#total_customers
#total_order quantity,total_products
#total_return_products
#total_returns

#1Find the total customer according to the state
select count(customer_id) from boat_customer;

#total-sale
select round(sum((quantity * unit_price)-(quantity *unit_price * discount_percent)/100)) as Total_Sale 
from order_detail ;

#total_order
select count(order_id) as total_order from order_boat;


#total_product
select count(product_id) as product from products;

#total_qty
#total_return
select count(return_id) as Total_returns from returns;

#2.find the customer according to the month
select monthname(registration_date) as months,
count(customer_id) as total_cust from boat_customer
group by months                                                  #where monthname(registration_date) ='september'
order by total_cust desc;
#3.find the num of order according to order state 
select 
     state, COUNT(customer_id) as total_customers
from boat_customer
group by state
order by total_customers desc;

#4.find the num of order according to order 
select monthname(order_date) as Months, count(order_id) as Total_orders
from order_boat
group by monthname(order_date)
order by Total_orders desc;

#5.find the tatal_sale amount according to payment method 
select
      ob.payment_method,
sum(od.amount)as total_amount
      from order_boat ob
      left join order_detail od
      on ob.order_id = od.order_id
      group by ob.payment_method
      order by total_amount;


alter table order_detail 
add column Amount decimal(12,2); 

set sql_safe_updates = 0; 
update order_detail 
set Amount = (quantity * unit_price) - ((quantity * unit_price)*(discount_percent/100)) where Amount is Null;

#6.find the total quantity accordind to the order channel
select
order_channel,
count(order_id) as total_orders
from order_boat
group by order_channel
order by total_orders desc;

#7.find the month name which month sale is maxium
SELECT MONTHNAME(customer_id) as total_sale from boat_customer
WHERE customer_id  = (SELECT MAX(customer_id) from boat_customer);


#8.which catogry has maximum products.
SELECT 
    category,
    COUNT(product_id) AS total_products
FROM products
GROUP BY category
ORDER BY total_products DESC
LIMIT 1;

#9.compare the total_products and total return product according to cetogery
SELECT 
    p.category,
    COUNT(od.order_detail_id) AS total_products,
    COUNT(r.return_id) AS total_return_products
FROM products p
JOIN order_detail od
    ON p.product_id = od.product_id
LEFT JOIN returns r
    ON od.order_detail_id = r.order_detail_id
GROUP BY p.category;

#10.find the top five products in 30 days.
SELECT 
    p.product_id,
    p.product_name,
    SUM(od.quantity) AS total_sold
FROM products p
JOIN order_detail od
    ON p.product_id = od.product_id
JOIN order_boat o
    ON od.order_id = o.order_id
WHERE o.order_date >= CURRENT_DATE - INTERVAL 30 DAY
GROUP BY p.product_id, p.product_name
ORDER BY total_sold DESC
LIMIT 5;

#11.find the top five product according the quantity in october month..
SELECT 
    p.product_id,
    p.product_name,
    SUM(od.quantity) AS total_quantity
FROM products p
JOIN order_detail od
    ON p.product_id = od.product_id
JOIN order_boat o
    ON od.order_id = o.order_id
WHERE MONTH(o.order_date) = 10
GROUP BY p.product_id, p.product_name
ORDER BY total_quantity DESC
LIMIT 5;

#BOAT QUESTIONS 
#Q1.Which cities have high customer count but low revenue contribution?
select 
    bc.city,
    count(distinct bc.customer_id) as total_customer,
    sum(od.amount) as revenue
    from boat_customer bc
    left join order_boat ob
    on bc. customer_id=ob.customer_id
    left join order_detail od
    on ob. order_id=od.order_id
    group by city
    order  by revenue asc , total_customer desc;


#Q2.What percentage of customers place more than one order?
select 
      bc.customer_id,
      count(ob.order_id) as total_order
      from boat_customer bc
      left join order_boat ob
      on bc. customer_id=ob.customer_id
      group by bc.customer_id
      having total_order>1;
      


#Q3.Which products have high sales but low profit potential?
SELECT 
    p.product_name,
    SUM(o.quantity * o.unit_price) AS total_sales,
    AVG(o.discount_percent) AS avg_discount
FROM Order_Detail o
JOIN Products p
ON o.product_id = p.product_id
GROUP BY p.product_name
HAVING 
    SUM(o.quantity * o.unit_price) > 50000
    AND AVG(o.discount_percent) > 20;
    
    
#Q4.Find products whose price is higher than the average product price.
SELECT 
    product_id,
    product_name,
    MRP
FROM Products
WHERE MRP > (
        SELECT AVG(MRP)
        FROM Products
);


#Q5.Find customers who have never returned any product.
SELECT 
   c.customer_id,
   c.name
FROM boat_Customer c
WHERE c.customer_id NOT IN
      (SELECT customer_id FROM Returns);
#Q6.Find customers who placed orders but never placed repeat orders
SELECT 
    c.customer_id,
    c.name,
    c.last_name,
    COUNT(o.order_id) AS total_orders
FROM boat_customer c
JOIN order_boat o
ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name, c.last_name
HAVING COUNT(o.order_id) = 1;


#Q7.Find products that belong to the category with highest revenue.
SELECT p.product_id, p.product_name, p.category
FROM products p
WHERE p.category = (
        SELECT p.category
        FROM products p
        JOIN order_detail od
        ON p.product_id = od.product_id
        GROUP BY p.category
        ORDER BY SUM(od.quantity * od.unit_price) DESC
        LIMIT 1
);

#Q8.Find products with return rate higher than overall return rate.
SELECT 
    p.product_id,
    p.product_name,
    COUNT(r.return_id) * 1.0 / COUNT(od.order_detail_id) AS product_return_rate
FROM products p
JOIN order_detail od 
    ON p.product_id = od.product_id
LEFT JOIN returns r 
    ON od.order_detail_id = r.order_detail_id
GROUP BY p.product_id, p.product_name
HAVING COUNT(r.return_id) * 1.0 / COUNT(od.order_detail_id) >
(
    SELECT 
        COUNT(r.return_id) * 1.0 / COUNT(od.order_detail_id)
    FROM order_detail od
    LEFT JOIN returns r
        ON od.order_detail_id = r.order_detail_id
);


#Q9.Find cities with lowest revenue but high return rate
SELECT 
    c.city,
    SUM(od.quantity * od.unit_price) AS total_revenue,
    COUNT(r.return_id) * 1.0 / COUNT(od.order_detail_id) AS return_rate
FROM boat_customer c
JOIN order_boat o
    ON c.customer_id = o.customer_id
JOIN order_detail od
    ON o.order_id = od.order_id
LEFT JOIN returns r
    ON od.order_detail_id = r.order_detail_id
GROUP BY c.city
ORDER BY total_revenue ASC, return_rate DESC;


#Q10.Find cities with highest quality-related returns.

SELECT 
    c.city,
    COUNT(r.return_id) AS quality_returns
FROM boat_customer c
JOIN order_boat o
    ON c.customer_id = o.customer_id
JOIN order_detail od
    ON o.order_id = od.order_id
JOIN returns r
    ON od.order_detail_id = r.order_detail_id
WHERE r.reason LIKE '%quality%'
GROUP BY c.city
ORDER BY quality_returns DESC;





























