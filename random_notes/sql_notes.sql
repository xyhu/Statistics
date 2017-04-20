####### Chapter 1 Data and Tables #############

# create a database called my_db
CREATE DATABASE my_db;

# use the database my_db
USE my_db;

# create table within the db, with 2 columns, 1st column allowing 10 chars, and second allowing 6 chars
CREATE TABLE names
(
	first_name VARCHAR(10),
	second_name VARCHAR(6) NOT NULL, # won't allow null value in this variable
	price DEC(3,2), # total number of digits to expect with number of digits after the decimal
	comments BLOB, # store large text > 255 chars
	quantity INT NOT NULL DEFAULT 1, # not null and with default value 1
	phone_number CHAR(10), # fixed number, always 10
	anniversary DATE, 
	meeting_time DATETIME # store future time, TIMESTAMP stores the current time
);

# creates from an existing table
#Following is an example, which would create a table SALARY using CUSTOMERS table and having fields customer ID and customer SALARY:

CREATE TABLE SALARY AS
   SELECT ID, SALARY
   FROM CUSTOMERS;


# describe your table
DESC names;

# Can't add column to the table, have to delete it first and create a new one
DROP TABLE names;

# to insert values into the table
INSERT INTO my_contacts ￼￼
(last_name, first_name, email, gender, birthday, profession, location, status, interests, seeking, quantity, price)
VALUES
('Anderson', 'Jillian', 'jill_anderson@ breakneckpizza.net', 'F', '1980-09-05',
'Technical Writer', 'Palo Alto, CA', 'Single', 'Kayaking, Reptiles', 'Relationship, Friends', 10, 3.45); # no quote for number

############ Chapter 2 the SELECT statement and advance SELECT ##################
# 1. select all variables
SELECT * FROM my_contacts;

# 2. subsetting based on certain variable
SELECT * FROM my_contacts
WHERE first_name = 'Anne'; # single equal sign, single quote

SELECT * FROM my_contacts
WHERE quantity = 10; # no quote for INT and DEC

SELECT * FROM my_contacts 
WHERE location = 'Grover\'s Mill, NJ'; # put a back slash before in-text quote sign

SELECT last_name, first_name FROM my_contacts;

SELECT location FROM doughnut_ratings
WHERE type = 'plain' AND rating = 10;

SELECT location FROM doughnut_ratings
WHERE type = 'plain' OR rating = 10;

SELECT location FROM doughnut_ratings
WHERE type <> 'plain'; # NOT EQUAL sign is so different!!!

SELECT drink_name 
FROM drink_info 
WHERE
drink_name >= 'L' # returns drink names whose first letter is L or later, based on alphabetical order
AND
drink_name < 'M'; # returns dirnk names whose first letter is before M

# select null values
SELECT drink_name FROM drink_info WHERE calories IS NULL;

# 3. look for values that ends with CA
SELECT * FROM my_contacts WHERE location LIKE '%CA'; # wild card % stands for any number of unknown characters
SELECT * FROM my_contacts WHERE location LIKE '_CA'; # wild card _ stands for one unknow character

# 4. select between a range
SELECT drink_name FROM drink_info WHERE calories BETWEEN 30 AND 60; # includes 30 and 60
SELECT drink_name FROM drink_info WHERE drink_name BETWEEN 'G' AND 'P'; # Not inclusive from the upper bound, drink names starts with G through O

# 5. Use of IN to replace multiple ORs
SELECT date_name FROM black_book WHERE rating IN ('innovative', 'fabulous', 'delightful', 'pretty good');
SELECT date_name FROM black_book WHERE rating NOT IN ('innovative', 'fabulous', 'delightful', 'pretty good');
￼
# 6. Use of NOT
SELECT date_name from black_book WHERE NOT date_name LIKE 'A%' AND NOT date_name LIKE 'B%'; # put NOT in fron of both statements
SELECT drink_name FROM drink_info WHERE NOT carbs BETWEEN 3 AND 5; # NOT in the range

# 7. select a specific number of characters, LEFT() or RIGHT()
SELECT RIGHT(location, 2) FROM my_contacts;

# 8. select everything before the first comma
SELECT SUBSTRING_INDEX(location, ',', 1) FROM my_contacts;

# 9. select starting at the start_position, with length number of chars
SELECT SUBSTRING(your_string, start_position, length)

# 10. select and convert to UPPER and LOWER case
SELECT UPPER('uSa');
SELECT LOWER('spaGHEtti');

# 11. select reverse the order of the chars
SELECT REVERSE('spaGHEtti');

# 12. Remove the empty space before/to the left
SELECT LTRIM(' dogfood ');

# 13. Remove the empty space after/to the right
SELECT RTRIM(' dogfood ');

# 14. number of characters
SELECT LENGTH('San Antonio, TX ');

# 15. select with ORDER
# select movies start with A and family type and order them alphabetically
SELECT title, category FROM movie_table WHERE title LIKE 'A%' AND category = 'family' ORDER BY title;
# select movies of family type and order them by names alphabetically
SELECT title, category FROM movie_table WHERE category = 'family' ORDER BY title;
# order two or more columns
SELECT title, category, purchase FROM movie_table ORDER BY category, purchase; # order by category first, then purchase
SELECT * FROM movie_table ORDER BY title, category, purchase;
# order by descending and ascending
SELECT * FROM movie_table ORDER BY title ASC, purchase DESC; # note DESC here is not describe

# 16. select with SUM
SELECT SUM(sales) FROM cookie_sales WHERE first_name = 'Nicole';
# sum by group
SELECT first_name, SUM(sales) FROM cookie_sales GROUP BY first_name ORDER BY SUM(sales)DESC;

# 17. select with AVG by group
SELECT first_name, AVG(sales) FROM cookie_sales GROUP BY first_name;

# 18. select with MIN, MAX by group
SELECT first_name, MIN(sales) FROM cookie_sales GROUP BY first_name;
SELECT first_name, MAX(sales) FROM cookie_sales GROUP BY first_name;

# 19. select with COUNT by group
SELECT first_name, COUNT(sale_date) FROM cookie_sales GROUP BY first_name;

# 20. select distinct values
SELECT DISTINCT sale_date FROM cookie_sales ORDER BY sale_date;
# count the number of distinct values
SELECT COUNT(DISTINCT sale_date) FROM cookie_sales;

# 21. LIMIT the result
# only provide the top 10 winners
SELECT first_name, SUM(sales) FROM cookie_sales GROUP BY first_name ORDER BY SUM(sales) DESC LIMIT 10;
# select certain rows, LIMIT start at index 0. first arg is starting position, second is the number of results to return
SELECT first_name, SUM(sales) FROM cookie_sales GROUP BY first_name ORDER BY SUM(sales) DESC LIMIT 19,10; # 20th - 29th records
############### Chapter 3 DELETE and UPDATE ##########
# delete only work for rows, not columns
DELETE FROM clown_info WHERE activities = 'dancing';

# delete all rows in a table
DELETE FROM clown_info

# DELETE vs SELECT: delete is performed directly on the table, select make a copy of what you select from the table

# to replace a value: INSERT a row with the changes, then DETELE the old row
INSERT INTO clown_info VALUES ('Clarabelle', 'Belmont Senior Center','F, pink hair, huge flower, blue dress', 'dancing');

DELETE FROM clown_info WHERE activities = 'yelling, dancing' AND name = 'Clarabelle';

# Change value with UPDATE
UPDATE doughnut_ratings SET type = 'glazed' WHERE type = 'plain glazed'; # this changes a specific row
UPDATE doughnut_ratings SET type = 'glazed'; # update all the type to glazed
UPDATE doughnut_ratings SET type = RIGHT(location, 2); # update with the values with a whole column
UPDATE my_contacts SET interests = SUBSTR(interests, LENGTH(interest1)+2 ); # delete chars upto LENGTH(interest1)+2
# update number by performing basic math
UPDATE drink_inf SET cost = cost + 1 WHERE drink_name = 'Blue Moon'

# UPDATE with case
UPDATE my_table
SET new_column = 
CASE
WHEN column1 = somevalue1 THEN newvalue1
WHEN column2 = somevalue2 AND column3 = somevalue3 THEN newvalue2
WHEN column4 = somevalue3 OR column5 = somevalue4 THEN newvalue3
ELSE newvalue4 
END;


########### Chapter 5 ALTER ##############
# 1. Add columns
ALTER TABLE my_contacts
ADD COLUMN contact_id INT NOT NULL AUTO_INCREMENT FIRST, # integer, not null, auto increment, placed in the first column
ADD PRIMARY KEY (contact_id); # use the new column as the primary key

# Add column in a specific position
ALTER TABLE my_contacts
ADD COLUMN phone VARCHAR(10) AFTER first_name; # add phone column after column first_name

# position keywords: BEFORE, AFTER, FIRST, SECOND, FIFTH, LAST

# 2. RENAME a table
ALTER TABLE projekts RENAME TO project_list;

# 3. CHANGE a column name and type
ALTER TABLE project_list
CHANGE COLUMN number proj_id INT NOT NULL AUTO_INCREMENT, # you have to give the renamed column a type
ADD PRIMARY KEY (proj_id);

# Change only the type of the column
ALTER TABLE project_list
MODIFY COLUMN proj_desc VARCHAR(10);

# 4. DROP a column
ALTER TABLE project_list
DROP COLUMN start_date;

# 5. MODIFY to move the locations of a column to a specific location, or before/after a column
ALTER TABLE project_list
MODIFY COLUMN start_date SIXTH,
MODIFY COLUMN proj_desc BEFORE start_date;
￼
￼
##################################################################################################

########## Start working with multiple tables #####################

# A description of the data (the columns and tables) in your database, along with any other related objects and the way they all connect is known as a SCHEMA

# PRIMARY KEY: primary unique ID of the table
# FOREIGN KEY: unique ID that links to other table, can be NULL, don’t have to be unique
# Creating a FOREIGN KEY as a constraint in your table gives you definite advantages. You’ll get errors if you violate the rules, which will stop you accidentally doing anything to break the table. You will only be able to insert values into your foreign key that exist in the table the key came from, the parent table. This is called referential integrity.
CREATE TABLE interests (
int_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY, # first variable int_id with some key words
interest VARCHAR(50) NOT NULL, # second variable
fr_contact_id INT NOT NULL, # third variable
CONSTRAINT my_contacts_contact_id_fk FOREIGN KEY (fr_contact_id) REFERENCES my_contacts (contact_id)
);

# my_contacts_contact_id_fk is the name of the constraint
# fr_contact_id is set as foreign key
# it is referenced from table my_contacts variable contact_id


# Parent key: The primary key used by a foreign key is also known as a parent key.
# Parent table: The table where the primary key is from is known as a parent table.


# Many-to-Many: a junction table holds a key from each table.

# Create, select and insert all at the same time
CREATE TABLE profession
￼( id INT(11) NOT NULL AUTO_INCREMENT PRIMARY KEY, profession varchar(20)) 
AS
SELECT profession FROM my_contacts GROUP BY profession ORDER BY profession;

# create ALIAS using AS
SELECT profession AS mc_prof FROM my_contacts AS mc GROUP BY mc_prof ORDER BY mc_prof;

# The CROSS JOIN returns every row from one table crossed with every row from the second.
SELECT t.toy, b.boy FROM toys AS t CROSS JOIN boys AS b;
SELECT toys.toy, boys.boy FROM toys, boys; # you can leave out cross join, achieve same result as above

# An INNER JOIN is a CROSS JOIN with some result rows removed by a condition in the query.
SELECT mc.last_name, mc.first_name, p.profession
FROM my_contacts AS mc INNER JOIN profession AS p
ON mc.prof_id = p.prof_id; # where the contact_id from my_contacts matches the id field in the profession table, can take not equal <>

# NATURAL JOIN inner joins identify matching column names. will recognize the same column name in each table and return matching rows
SELECT boys.boy, toys.toy FROM boys NATURAL JOIN toys;

# subquery
# outer query + inner query = a query with subquery
SELECT some_column, another_column
FROM table
WHERE column = (SELECT column FROM table); # equal sign returns a single row, can also replace it with IN

SELECT last_name, first_name
FROM my_contacts
WHERE zip_code = (SELECT zip_code FROM zip_code WHERE city = 'Memphis' AND state = 'TN');

# WHERE EXISTS ( subquery );
# The subquery is a SELECT statement. If the subquery returns at least one record in its result set, the EXISTS clause will 
# evaluate to true and the EXISTS condition will be met. If the subquery does not return any records, the EXISTS clause will 
# evaluate to false and the EXISTS condition will not be met.

# It is a very inefficient way since the code re-run through the data in the subquery
SELECT mc.first_name firstname, mc.last_name lastname, mc.email email FROM my_contacts mc
WHERE EXISTS # NOT EXISTS
(SELECT * FROM contact_interest ci WHERE mc.contact_id = ci.contact_id );

# OUTER JOIN: The left outer join matches EVERY ROW in the LEFT table with a row from the right table.
# In a LEFT OUTER JOIN, the table that comes after FROM and BEFORE the join is the LEFT table, and the table that comes AFTER the join is the RIGHT table.
# The difference is that an outer join gives you a row whether there’s a match with the other table or not.
# A NULL value in the results of a left outer join means that the right table has no values that correspond to the left table.

# INNER JOIN: merge data with exact matches
# OUTER JOIN: merge data including rows that don't match
# LEFT OUTER JOIN: results include all values of the column from the LEFT TABLE, and some may repeat multiple times
SELECT g.girl, t.toy FROM toys t LEFT OUTER JOIN girls g ON g.toy_id = t.toy_id;
# RIGHT OUTER JOIN: The right outer join is exactly the same thing as the left outer join, except it compares the right table to the left one. Results include all values of the column from the RIGHT TABLE
SELECT g.girl, t.toy FROM toys t RIGHT OUTER JOIN girls g ON g.toy_id = t.toy_id;

# The self-join allows you to query a single table as though there were two tables with exactly the same information in them.
SELECT c1.name, c2.name AS boss 
FROM clown_info c1
INNER JOIN clown_info c2
ON c1.boss_id = c2.id;

# A UNION combines the results of two or more queries into one table, based on what you specify in the column list of the SELECT. 
SELECT title FROM job_current
UNION
SELECT title FROM job_desired
UNION
SELECT title FROM job_listings;

SELECT title FROM job_current ORDER BY title # only one ORDER BY
UNION
SELECT title FROM job_desired ORDER BY title 
UNION
SELECT title FROM job_listings ORDER BY title;

SELECT title FROM job_current 
UNION
SELECT title FROM job_desired 
UNION
SELECT title FROM job_listings ORDER BY title; # order the final results in the end

SELECT title FROM job_current
UNION ALL
SELECT title FROM job_desired
UNION ALL
SELECT title FROM job_listings ORDER BY title;

# UNION: returns unique results
# UNION ALL: return duplicated results

# INTERSECT
SELECT title FROM job_current
INTERSECT
SELECT title FROM job_desired;

# EXCEPT: returns only those columns that are in the first query, but not in the second query.
SELECT title FROM job_current
EXCEPT
SELECT title FROM job_desired;

############ LEFTOVERS ##############
# to change a data type
SELECT CAST(your_column, TYPE);
SELECT CAST(your_column AS TYPE);

# HAVING: The HAVING clause was added to SQL because the WHERE keyword could not be used with aggregate functions.
# A "Single Item Order" is a customer order where only one item is ordered. Show the SalesOrderID and the UnitPrice for every Single Item Order.
SELECT SalesOrderID, COUNT(SalesOrderID) AS c, UnitPrice FROM SalesOrderDetail NATURAL JOIN ProductAW GROUP BY SalesOrderID HAVING c= 1


# For each order show the SalesOrderID and SubTotal calculated three ways: 
#A) From the SalesOrderHeader 
#B) Sum of OrderQty*UnitPrice 
#C) Sum of OrderQty*ListPrice
SELECT SalesOrderDetail.SalesOrderID, SubTotal, SUM(OrderQty*UnitPrice) AS B, SUM(OrderQty*ListPrice) AS C 
FROM SalesOrderHeader JOIN SalesOrderDetail ON SalesOrderHeader.SalesOrderID = SalesOrderDetail.SalesOrderID 
JOIN ProductAW ON SalesOrderDetail.ProductID = ProductAW.ProductID 
GROUP BY SalesOrderDetail.SalesOrderID;

#Show the best selling item by value.
SELECT Name, SUM(OrderQty), SUM(OrderQty*UnitPrice) AS B, SUM(OrderQty*ListPrice) AS C 
FROM SalesOrderDetail JOIN ProductAW ON SalesOrderDetail.ProductID = ProductAW.ProductID 
GROUP BY Name ORDER BY SUM(OrderQty) DESC LIMIT 10;

# Show how many orders are in the following ranges (in $):
SELECT
           CASE
               WHEN SalesOrderHeader.SubTotal + SalesOrderHeader.TaxAmt + SalesOrderHeader.Freight < 100 THEN "0-99"
               WHEN SalesOrderHeader.SubTotal + SalesOrderHeader.TaxAmt + SalesOrderHeader.Freight BETWEEN 100 and 999 THEN "100-999"
               WHEN SalesOrderHeader.SubTotal + SalesOrderHeader.TaxAmt + SalesOrderHeader.Freight BETWEEN 1000 and 9999 THEN "1000-9999"
               WHEN SalesOrderHeader.SubTotal + SalesOrderHeader.TaxAmt + SalesOrderHeader.Freight >10000 THEN "RICH BITCH"
          END AS t, 
          COUNT(*) AS Num,   
            CASE
               WHEN SalesOrderHeader.SubTotal + SalesOrderHeader.TaxAmt + SalesOrderHeader.Freight < 100 THEN SUM(SalesOrderHeader.SubTotal + SalesOrderHeader.TaxAmt + SalesOrderHeader.Freight)
               WHEN SalesOrderHeader.SubTotal + SalesOrderHeader.TaxAmt + SalesOrderHeader.Freight BETWEEN 100 and 999 THEN SUM(SalesOrderHeader.SubTotal + SalesOrderHeader.TaxAmt + SalesOrderHeader.Freight)
               WHEN SalesOrderHeader.SubTotal + SalesOrderHeader.TaxAmt + SalesOrderHeader.Freight BETWEEN 1000 and 9999 THEN SUM(SalesOrderHeader.SubTotal + SalesOrderHeader.TaxAmt + SalesOrderHeader.Freight)
               WHEN SalesOrderHeader.SubTotal + SalesOrderHeader.TaxAmt + SalesOrderHeader.Freight >10000 THEN SUM(SalesOrderHeader.SubTotal + SalesOrderHeader.TaxAmt + SalesOrderHeader.Freight) END

FROM SalesOrderHeader
GROUP BY t;

# List the ProductName and the quantity of what was ordered by 'Futuristic Bikes'
SELECT ProductAW.Name, SalesOrderDetail.OrderQty, CompanyName FROM  SalesOrderDetail 
JOIN 
ProductAW ON SalesOrderDetail.ProductID = ProductAW.ProductID 
JOIN 
SalesOrderHeader ON SalesOrderDetail.SalesOrderID = SalesOrderHeader.SalesOrderID 
JOIN 
CustomerAW ON SalesOrderHeader.CustomerID = CustomerAW.CustomerID 
WHERE CompanyName = "Futuristic Bikes";


# List the name and addresses of companies containing the word 'Bike' (upper or lower case) and 
# 55companies containing 'cycle' (upper or lower case). Ensure that the 'bike's are listed before the 'cycles's.
SELECT CompanyName, AddressLine1 
FROM CustomerAW 
JOIN CustomerAddress ON CustomerAW.CustomerID = CustomerAddress.CustomerID 
JOIN Address ON CustomerAddress.AddressID = Address.AddressID 
WHERE CompanyName LIKE "%bike%" OR CompanyName LIKE "%cycle%" 
ORDER BY 
CASE 
WHEN CompanyName LIKE "%bike%" THEN 1
WHEN CompanyName LIKE "%cycle%" THEN 2
END;


# Replace function
# It depends on what you need to do. You can use replace since you want to replace the value:

select replace(email, '.com', '.org')
from yourtable
# Then to UPDATE your table with the new ending, then you would use:

update yourtable
set email = replace(email, '.com', '.org')
# You can also expand on this by checking the last 4 characters of the email value:

update yourtable
set email = replace(email, '.com', '.org')
where right(email, 4) = '.com'
# However, the issue with replace() is that .com can be will in other locations in the email not just the last one. So you might want to use substring() the following way:

update yourtable
set email = substring(email, 1, len(email) -4)+'.org'
where right(email, 4) = '.com';

# Select dates between two dates
you should put those two dates between single quotes like..

select Date, TotalAllowance from Calculation where EmployeeId = 1
             and Date between '2011/02/25' and '2011/02/27'

# paste two string
SELECT CustCity AS City, Concat(CustLastName, ', ', CustFirstName) AS Customer
FROM Customers
ORDER BY City, Customer;

# date and time arithmetic
# DATE plus or minus INTERVAL yields DATE
# DATE minus DATE yields INTERVAL
# INTERVAL plus DATE yields DATE
# INTERVAL plus or minus INTERVAL yields INTERVAL INTERVAL times or divided by NUMBER yields INTERVAL

# In MySQL
# Returns the current date and time
NOW() 
# Returns the current date
CURDATE() 
# Returns the current time
CURTIME() 
# Extracts the date part of a date or date/time expression
DATE()  
# Returns a single part of a date/time
EXTRACT(unit FROM date)

# Unit Value
MICROSECOND
SECOND
MINUTE
HOUR
DAY
WEEK
MONTH
QUARTER
YEAR
SECOND_MICROSECOND
MINUTE_MICROSECOND
MINUTE_SECOND
HOUR_MICROSECOND
HOUR_SECOND
HOUR_MINUTE
DAY_MICROSECOND
DAY_SECOND
DAY_MINUTE
DAY_HOUR
YEAR_MONTH

SELECT EXTRACT(YEAR FROM OrderDate) AS OrderYear,
EXTRACT(MONTH FROM OrderDate) AS OrderMonth,
EXTRACT(DAY FROM OrderDate) AS OrderDay,
FROM Orders
WHERE OrderId=1

# Adds a specified time interval to a date
DATE_ADD(date,INTERVAL expr type)

SELECT OrderId,DATE_ADD(OrderDate,INTERVAL 45 DAY) AS OrderPayDate
FROM Orders

# Type Value
MICROSECOND
SECOND
MINUTE
HOUR
DAY
WEEK
MONTH
QUARTER
YEAR
SECOND_MICROSECOND
MINUTE_MICROSECOND
MINUTE_SECOND
HOUR_MICROSECOND
HOUR_SECOND
HOUR_MINUTE
DAY_MICROSECOND
DAY_SECOND
DAY_MINUTE
DAY_HOUR
YEAR_MONTH
# Subtracts a specified time interval from a date 
DATE_SUB(date,INTERVAL expr type)

# Returns the number of days between two dates
DATEDIFF(date1,date2)

SELECT DATEDIFF('2014-11-30','2014-11-29') AS DiffDate
# Displays date/time data in different formats
DATE_FORMAT(date,format)

DATE_FORMAT(NOW(),'%b %d %Y %h:%i %p')


# View
CREATE VIEW CH05_First_Performance_Review
AS 
SELECT Concat(AgtLastName, ', ', AgtFirstName) AS Agent, DateHired, Date_Add(DateHired, Interval 180 Day) AS FirstReview
FROM Agents
ORDER BY Agent;

# Replace
# Update all rows in table1, replacing records where itemDescription has a "%$" with a ":"
# assumimg that the percent sign is not wildcard.
UPDATE table1 SET itemDescription = REPLACE(itemDescription, “%$”, “:”);

# What does a COMMIT do?
# It is used as the end of all SQL transactions and makes the changes made by the transactions permanent to the database.

SELECT IF(rating > 4, "good", "bad") as rating, count(*) as cnt from amazon group by IF(rating > 4, "good", "bad") order by rating;


# Working with a derived table without creating one in the database
WITH stack_usergeo AS (
SELECT 
e.user_id AS user_id
, e.latitude AS latitude
, e.longitude AS longitude
, e.time_modified AS time_modified
FROM public.emma_usergeo AS e
UNION
SELECT
k.user_id AS user_id
, k.latitude AS latitude
, k.longitude AS longitude
, k.time_modified AS time_modified
FROM public.kaylee_usergeo AS k
)
SELECT 
	stack_usergeo.user_id AS "stack_usergeo.user_id",
	COUNT(*) AS "stack_usergeo.count"
FROM stack_usergeo

GROUP BY 1
ORDER BY 2 DESC
LIMIT 500