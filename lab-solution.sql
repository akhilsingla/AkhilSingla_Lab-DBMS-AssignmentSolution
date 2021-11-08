create database MyOnlineDatabase;
USE MyOnlineDatabase;

CREATE TABLE IF NOT EXISTS Supplier(
SUPP_ID int PRIMARY KEY,
SUPP_NAME varchar(30),
SUPP_CITY varchar(50),
SUPP_PHONE varchar(20)
);


CREATE TABLE IF NOT EXISTS Customer(
CUS_ID int PRIMARY KEY,
CUS_NAME varchar(50),
CUS_PHONE varchar(20),
CUS_CITY varchar(50),
CUS_GENDER char
);

CREATE TABLE IF NOT EXISTS Category(
CAT_ID int PRIMARY KEY,
CAT_NAME varchar(50)
);

CREATE TABLE IF NOT EXISTS Product(
PRO_ID int PRIMARY KEY,
PRO_NAME varchar(50),
PRO_DESC varchar(100),
CAT_ID int,
FOREIGN KEY (CAT_ID) REFERENCES Category(CAT_ID)
);

CREATE TABLE IF NOT EXISTS Product_Details(
PROD_ID int PRIMARY KEY,
PRO_ID int,
SUPP_ID int,
PROD_PRICE decimal(20,2),
FOREIGN KEY(PRO_ID) REFERENCES Product(PRO_ID),
FOREIGN KEY(SUPP_ID) REFERENCES Supplier(SUPP_ID)
);

CREATE TABLE IF NOT EXISTS MyOnlineDatabase.Order(
ORD_ID int PRIMARY KEY,
ORD_AMOUNT decimal(20,2),
ORD_DATE date,
CUS_ID int,
PROD_ID int,
FOREIGN KEY(CUS_ID) REFERENCES Customer(CUS_ID),
FOREIGN KEY(PROD_ID) REFERENCES Product_Details(PROD_ID)
);

CREATE TABLE IF NOT EXISTS Rating(
RAT_ID int PRIMARY KEY,
CUS_ID int,
SUPP_ID int,
RAT_RATSTARS int,
FOREIGN KEY(CUS_ID) REFERENCES Customer(CUS_ID),
FOREIGN KEY(SUPP_ID) REFERENCES Supplier(SUPP_ID)
);

INSERT INTO Supplier Values
(1, "Rajesh Retails", "Delhi", 1234567890),
(2, "Appario Ltd.", "Mumbai", 2589631470),
(3, "Knome products", "Banglore", 9785462315),
(4, "Bansal Retails", "Kochi", 8975463285),
(5, "Mittal Ltd.", "Lucknow", 7898456532);

select * from Supplier;

INSERT INTO Customer Values
(1, "AAKASH", "9999999999", "DELHI", "M"),
(2, "AMAN", "9785463215", "NOIDA", "M"),
(3, "NEHA", "9999999999", "MUMBAI", "F"),
(4, "MEGHA", "9994562399", "KOLKATA", "F"),
(5, "PULKIT", "7895999999", "LUCKNOW", "M");

select * from Customer;

INSERT INTO Category Values
(1, "BOOKS"),
(2, "GAMES"),
(3, "GROCERIES"),
(4, "ELECTRONICS"),
(5, "CLOTHES");

select * from Category;

INSERT INTO Product Values
(1, "GTA V", "DFJDJFDJFDJFDJFJF", 2),
(2, "TSHIRT", "DFDFJDFJDKFD", 5),
(3, "ROG LAPTOP", "DFNTTNTNTERND", 4),
(4, "OATS", "REURENTBTOTH", 3),
(5, "HARRY POTTER", "NBEMCTHTJTH", 1);

select * from Product;

INSERT INTO Product_Details Values
(1, 1, 2, 1500),
(2, 3, 5, 30000),
(3, 5, 1, 3000),
(4, 2, 3, 2500),
(5, 4, 1, 1000);

select * from Product_Details;


INSERT INTO MyOnlineDatabase.Order Values
(20, 1500, "2021-10-12", 3, 5),
(25, 30500, "2021-09-16", 5, 2),
(26, 2000, "2021-10-05", 1, 1),
(30, 3500, "2021-08-16", 4, 3),
(50, 2000, "2021-10-06", 2, 1);

select * from MyOnlineDatabase.Order;

INSERT INTO Rating Values
(1, 2, 2, 4),
(2, 3, 4, 3),
(3, 5, 1, 5),
(4, 1, 3, 2),
(5, 4, 5, 4);

select * from MyOnlineDatabase.Rating;

## query 3
select Customer.CUS_GENDER AS Customer_Gender, COUNT(MyOnlineDatabase.Order.CUS_ID) AS Number_of_Customers 
from Customer, MyOnlineDatabase.Order where Customer.CUS_ID = MyOnlineDatabase.Order.CUS_ID And MyOnlineDatabase.Order.ORD_AMOUNT >= 3000 Group by Customer.CUS_GENDER;

## query 4
select MyOnlineDatabase.Order.*, Product_Details.PRO_ID, Product.PRO_NAME from (MyOnlineDatabase.Order
INNER JOIN Product_Details ON MyOnlineDatabase.Order.PROD_ID = Product_Details.PROD_ID AND MyOnlineDatabase.Order.CUS_ID = 2)
INNER JOIN Product ON Product_Details.PRO_ID = Product.PRO_ID;

## query 5
select Supplier.* from Supplier where Supplier.SUPP_ID IN (Select SUPP_ID from Product_Details group by SUPP_ID having count(SUPP_ID) > 1);

## query 6
select Category.* from Category where CAT_ID IN 
(
 select CAT_ID from Product where PRO_ID IN 
 (
	select PRO_ID from Product_Details where PROD_ID IN 
    (
		select PROD_ID from MyOnlineDatabase.Order where ORD_AMOUNT = (Select min(ORD_AMOUNT) from MyOnlineDatabase.Order)
	)
 )
);

## query 7
select PRO_ID, PRO_NAME from Product where PRO_ID IN (
	select Product_Details.PRO_ID from Product_Details INNER JOIN MyOnlineDatabase.Order ON MyOnlineDatabase.Order.PROD_ID = Product_Details.PROD_ID 
    AND MyOnlineDatabase.Order.ORD_DATE > "2021-10-05"
);

## query 8
select Supplier.SUPP_ID, Supplier.SUPP_NAME, Customer.CUS_NAME, S.RAT_RATSTARS from (Supplier 
INNER JOIN (select * from Rating order by RAT_RATSTARS desc limit 3) AS S ON Supplier.SUPP_ID = S.SUPP_ID)
INNER JOIN Customer ON S.CUS_ID = Customer.CUS_ID;

## query 9
select CUS_NAME, CUS_GENDER from Customer where CUS_NAME LIKE '%A' or CUS_NAME LIKE 'A%';

## query 10
select Customer.CUS_GENDER, SUM(MyOnlineDatabase.Order.ORD_AMOUNT) AS "Total Order Sum of Male Customers" from Customer 
INNER JOIN MyOnlineDatabase.Order ON MyOnlineDatabase.Order.CUS_ID = Customer.CUS_ID AND Customer.CUS_GENDER = "M";

## query 11
select Customer.*, MyOnlineDatabase.Order.* from Customer LEFT OUTER JOIN MyOnlineDatabase.Order ON Customer.CUS_ID = MyOnlineDatabase.Order.CUS_ID;

## query 12
DROP PROCEDURE IF EXISTS get_supplier_verdict;
DELIMITER &&  
CREATE PROCEDURE get_supplier_verdict()  
BEGIN  
select Supplier.SUPP_ID, Supplier.SUPP_NAME, Rating.RAT_RATSTARS,
CASE WHEN Rating.RAT_RATSTARS > 4 THEN "Genuine Supplier"
WHEN Rating.RAT_RATSTARS > 2 THEN "Average Supplier"
ELSE "Supplier should not be considered" END AS Verdict from Supplier INNER JOIN Rating ON Supplier.SUPP_ID = Rating.SUPP_ID;
END && 
DELIMITER 

call get_supplier_verdict();

