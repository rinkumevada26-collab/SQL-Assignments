use classicmodels;
select * from employees;
--  Q1(a)
select employeeNumber,firstName,lastName from employees where jobTitle ="'Sales Rep" or reportsto=1102;

-- Q1(b)
select * from products;
select distinct productline from products where productline like "%cars";

-- Q2
Select * from customers;
select customerNumber,customerName,case
when country in ('USA','Canada') then "North America"
when country in ('UK','France','Germany') then "Europe"
else "Others"
end
as CustomerSegment from customers;

-- Q3(a)
select * from orderdetails;
select productcode,sum(quantityOrdered) as Total_Ordered from orderdetails group by productcode order by total_ordered desc limit 10;

-- Q3(b)
select * from payments;
select monthname(paymentdate) as Payment_Month,count(paymentdate) as Num_Payments from payments group by payment_month having count(*)>20 
order by num_payments desc;

-- Q4
create database Customers_orders;
use customers_orders;

-- Q4(a)
create table customers(Customer_id int primary key auto_increment,First_Name varchar(50) not null,Last_Name varchar(50) not null,
email varchar(255) unique,Phone_Number varchar(20));
desc customers;

-- Q4(b)
create table Orders(order_id int primary key auto_increment,
             customer_id int, foreign key(customer_id) references customers(customer_id),
             Order_Date date,
             Total_Amount decimal(10,2) check (Total_Amount>0));
desc orders;

-- Q5(a)
use classicmodels;
select * from customers;
select * from orders;
select customers.country,count(orders.ordernumber) as order_count from customers join orders on 
customers.customerNumber=orders.customerNumber group by customers.country order by order_count desc limit 5;

-- Q6(a)
use customers_orders;
create table Project(EmployeeID int primary key auto_increment ,FullName varchar(50) not null,Gender enum ("Male","Female"),ManagerID int);
insert into Project (FullName,Gender,ManagerID) values ("Pranaya","Male",3),("Priyanka","Female",1),("Preety","Female",null),
                           ("Anurag","Male",1),("Sambit","Male",1),("Rajesh","Male",3),("Hina","Female",3);
select * from Project;
select m.fullname as ManagerName,e.fullname as EmployeeName from project e inner join project m on m.employeeid=e.managerid 
order by e.managerid;

-- Q7(a)
create table facility(Facility_ID int,Name varchar(20),State varchar(20),Country varchar(20));
desc facility;
alter table facility modify column Facility_ID int primary key auto_increment;
alter table facility add column City varchar(20) not null after Name;
select * from facility;

-- Q8(a)
CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `root`@`localhost` 
    SQL SECURITY DEFINER
VIEW `classicmodels`.`product_category_sales` AS
    SELECT 
        `pl`.`productLine` AS `Category_Name`,
        SUM((`od`.`quantityOrdered` * `od`.`priceEach`)) AS `Total_sales`,
        COUNT(DISTINCT `o`.`orderNumber`) AS `Number_of_orders`
    FROM
        (((`classicmodels`.`productlines` `pl`
        JOIN `classicmodels`.`products` `p` ON ((`pl`.`productLine` = `p`.`productLine`)))
        JOIN `classicmodels`.`orderdetails` `od` ON ((`p`.`productCode` = `od`.`productCode`)))
        JOIN `classicmodels`.`orders` `o` ON ((`od`.`orderNumber` = `o`.`orderNumber`)))
    GROUP BY `pl`.`productLine`;

select * from product_category_sales;

-- Q9(a)
CREATE DEFINER=`root`@`localhost` PROCEDURE `Get_country_payments`(in input_year int,in input_ountry varchar(20))
DELIMITER 
BEGIN
select  year(p.paymentdate) as Payment_year,c.country as Country_name,concat(round(sum(p.amount)/1000,0),"K") as Total_amount
from customers c join payments p on c.customernumber=p.customernumber
where year(p.paymentdate)=input_year and c.country=input_country GROUP BY 
        Payment_year, Country_name;
END ;
use classicmodels;
call get_country_payments(2004,'USA');

-- Q10(a)
select c.customername,count(distinct o.ordernumber) as order_count,dense_rank()over (order by count(distinct o.ordernumber) desc) 
from customers c join orders o on c.customernumber=o.customernumber group by c.customername order by order_count desc;

-- Q10(b)
WITH OrderCounts AS (
    SELECT 
        YEAR(orderDate) AS order_year,
        MONTH(orderDate) AS order_month_number,
        MONTHNAME(orderDate) AS order_month,
        COUNT(orderNumber) AS order_count
    FROM Orders
    GROUP BY YEAR(orderDate), MONTH(orderDate), MONTHNAME(orderDate)
)
SELECT 
    order_year,
    order_month,
    order_count,
    CASE 
        WHEN LAG(order_count) OVER (PARTITION BY order_year ORDER BY order_month_number) IS NULL 
        THEN 'N/A'
        ELSE CONCAT(ROUND(
            ((order_count - LAG(order_count) OVER (PARTITION BY order_year ORDER BY order_month_number)) 
            / LAG(order_count) OVER (PARTITION BY order_year ORDER BY order_month_number)) * 100, 0), '%')
    END 
    AS YoY_change
FROM OrderCounts
ORDER BY order_year, order_month_number;

-- Q11
select productline as product_line,count(*)as Total from products where buyprice > (select avg(buyprice) from products) group by productline order by total desc;

-- Q12
create table Emp_EH(EmpID int auto_increment primary key,EmpName varchar(20) not null,EmailAddress Varchar(30)unique not null);
desc emp_EH;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `Inputemployee`(In E_empname varchar(20), in E_emailaddress varchar(50))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Error Occurred' AS message;
    END;
    START TRANSACTION;
    INSERT INTO Emp_EH (EmpName, EmailAddress)
    VALUES (E_empname, E_emailaddress);
    COMMIT;
END$$
DELIMITER ;
call inputemployee('Sam','sam2012@gmail.com');
call insertemployee('Hari','sam2012@gmail.com');

-- Q13
create table Emp_BIT(Name varchar(50) not null,Occupation varchar(50) not null,Working_date date not null,Working_hours int not null);
desc Emp_bit;
select * from emp_bit;
INSERT INTO Emp_BIT VALUES
('Robin', 'Scientist', '2020-10-04', 12),  
('Warner', 'Engineer', '2020-10-04', 10),  
('Peter', 'Actor', '2020-10-04', 13),  
('Marco', 'Doctor', '2020-10-04', 14),  
('Brayden', 'Teacher', '2020-10-04', 12),  
('Antonio', 'Business', '2020-10-04', 11);
DELIMITER //
CREATE DEFINER=`root`@`localhost` TRIGGER `emp_bit_BEFORE_INSERT` BEFORE INSERT ON `emp_bit` FOR EACH ROW 
BEGIN
IF new.working_hours < 0 THEN SET new.working_hours = abs(new.working_hours);
END IF;
END;
DELIMITER ;
insert into emp_bit values('Samuel','Teacher','2020-10-23',-8);
select * from emp_bit;