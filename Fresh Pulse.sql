create database amazon;
select * from amazon.order_details ;
select* from amazon.orders;
select* from amazon.products;
select * from amazon.reviews;
select*from amazon.suppliers;
select* from amazon.customer;


-- To Create an ER diagram for the Amazon Fresh database to understand the relationships between tables (e.g., Customers, Products, Orders).
-- To Identify the primary keys and foreign keys for each table and describe their relationships.

-- To Retrieve all customers from a specific city. ○ Fetch all products under the "Fruits" category.
select* from amazon.customer
where City like"South Richardside";

select*from amazon.products
where Category ="Fruits";

-- DDL statements to recreate the Customers table with the following constraints:
--  CustomerID as the primary key.
--  Ensure Age cannot be null and must be greater than 18.
--  Add a unique constraint for Name.

alter table amazon.customer modify Name varchar(100) unique;

-- Inserting 3 new rows into the Products table using INSERT statements.

insert into amazon.products(ProductID,ProductName,Category,SubCategory,PricePerUnit,StockQuantity,SupplierID)
Values("gf78yrewyg8duv983ejgbiudc89wq","Arun","Bakery","Sub-Bakery-2","387","278","gavsduyo738o8267yfhbgsdi"),
("sbdiu237r687yrhdhbs9","Amul","Dairy","Sub-Dairy","765","678","wedu643298uriwjbsfc98231uy"),
("b87q3tr812yqrufhbcqa9238rkjbfs","Vegiee","Vegetable","Sub-Vegetable-2","759","180","hbciuehyfehfijwbvoivjhoih7");

-- To Update the stock quantity of a product where ProductID matches a specific ID.

set sql_safe_updates=0;
update amazon.products set StockQuantity=500
where ProductID="0006853b-74cb-44a2-91ed-699aa31c5b5b";

-- To Delete a supplier from the Suppliers table where their city matches a specifi value.
delete from amazon.suppliers
where City="South Ana";

--  Using SQL constraints to:
-- Add a CHECK constraint to ensure that ratings in the Reviews table are between 1 and 5.
-- Add a DEFAULT constraint for the PrimeMember column in the Customers table (default value: "No").

alter table amazon.reviews add check (Rating between 1 and 5);
alter table amazon.customer modify PrimeMember varchar(50) default"No";

-- queries using:
-- WHERE clause to find orders placed after 2024-01-01.
 select * from amazon.orders
 where OrderDate>"2024-01-01";
 
 -- HAVING clause to list products with average ratings greater than 4.
 select p.ProductName as ProductName,r.ProductID as ProductID,avg(r.Rating)as avg_Rating from amazon.products as p
 left join amazon.reviews as r
 on p.ProductID=r.ProductID
 group by p.ProductName,r.ProductID
 having avg(r.Rating) >4;

-- GROUP BY and ORDER BY clauses to rank products by total sales.
select OrderID,CustomerID,sum(OrderAmount+DeliveryFee) as totalsales,Rank()
over(order by sum(OrderAmount+DeliveryFee) desc) as ranks from amazon.orders
group by OrderID,CustomerID;
 
 -- Identifying High-Value Customers
-- Scenario:
-- Amazon Fresh wants to identify top customers based on their total spending. We will:

-- 1. Calculate each customer's total spending.
 select c.Name as Name,c.CustomerID as Customer_ID,sum(o.OrderAmount+o.DeliveryFee) as Total_spending from amazon.customer as c
 left join amazon.orders as o
 on c.CustomerID = o.CustomerID
 group by c.Name,c.CustomerID;
 
 -- 2. Rank customers based on their spending.
 select Name,Customer_ID,Total_spending,Rank()
 over(order by Total_spending desc)as ranks from 
 ( select c.Name as Name,c.CustomerID as Customer_ID,sum(o.OrderAmount+o.DeliveryFee) as Total_spending from amazon.customer as c
 left join amazon.orders as o
 on c.CustomerID = o.CustomerID
 group by c.Name,c.CustomerID)as customer;
 
 -- 3. Identify customers who have spent more than ₹5,000.
 select c.Name as Name,c.CustomerID as Customer_ID,sum(o.OrderAmount+o.DeliveryFee) as Total_spending from amazon.customer as c
 left join amazon.orders as o
 on c.CustomerID = o.CustomerID
 group by c.Name,c.CustomerID
 having Total_spending>5000;
 
 
 -- Complex Aggregations and Joins
--  Using SQL to:

-- Join the Orders and OrderDetails tables to calculate total revenue per order.

select d.OrderID as orderID,SUM(OrderAmount)as Total_Revenue from amazon.Order_details as o
left join amazon.orders as d
on o.OrderID = D.OrderID
group by d.OrderID;

 -- Identify customers who placed the most orders in a specific time period.
 Select c.CustomerID as CustomerID,count(c.CustomerID)as Most_orders from amazon.Customer as c
 left join amazon.orders as o
 on c.CustomerID = o.CustomerID
 where o.OrderDate>"2024-01-01"
 group by c.CustomerID
 order by Most_orders desc;


-- Find the supplier with the most products in stock.

Select SupplierID,sum(StockQuantity) from amazon.products
group by SupplierID
order by sum(StockQuantity) desc
limit 1;

-- To Normalize the Products table to 3NF:
--  Separate product categories and subcategories into a new table.
--  Create foreign keys to maintain relationships.
create table amazon.Categories(ProductID varchar(100),ProductName varchar(100),Category varchar(100));
insert into amazon.Categories( ProductID,ProductName,Category)
values ("0006853b-74cb-44a2-91ed-699aa31c5b5b","Enter Dair","Dairy"),
("0297061c-1241-4540-ac99-ac6a44fa507e","Word Fruit","Meat"),
("030ff542-d5f3-4387-9654-90ae0e38702c","Room Snack","Snacks"),
("0fd54576-f933-4c77-8c7e-d5d482ff2e4e","Push Snack","Snacks"),
("11c83d33-0898-4711-84f5-0da2e020c8c5","Door Vegetable","Vegetables");

create table amazon.SubCategory(ProductID varchar(100),SubCategory varchar(100));
insert into amazon.SubCategory(ProductID,SubCategory)
values ("11c83d33-0898-4711-84f5-0da2e020c8c5","Available Snack"),
("16afe3ad-9f99-4d55-872c-770517390636","Those Vegetable"),
("1c9a5e6a-c81a-45e7-9e2a-e0e138bc77c3","Now Mea"),
("1d448b67-ae57-4533-a557-b80089e9927b","Report Fruit"),
("227a27e8-1737-45e6-a532-dc56eff6ef0f","Truth Baker");

-- Subqueries and Nested Queries
-- subquery to:
-- Identify the top 3 products based on sales revenue.

select o.ProductID as ProductID, Total_sales from amazon.order_details as o
join (select ProductID, SUM(PricePerUnit*StockQuantity) as Total_sales from amazon.products
group by ProductID) as p
on p.ProductID =o.ProductID
order by Total_sales desc
limit 3;

-- To Find customers who haven’t placed any orders yet.

select(select CustomerID from  amazon.orders
where OrderID is null) as No_orders_placed,Name from amazon.customer;


-- TO Provide actionable insights:
-- Which cities have the highest concentration of Prime members?

select City,count(PrimeMember) from amazon.customer
group by city
order by count(PrimeMember) desc;

-- What are the top 3 most frequently ordered categories ?
select category,count(ProductID)as orders from amazon.products
group by category
order by count(ProductID)desc;

