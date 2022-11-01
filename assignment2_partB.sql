/***********************************************
** File: Assignment2-PartB.sql
** Desc: Manipulating, Categorizing, Sorting and Grouping & Summarizing Data 
** Author: Luke Schwenke
** Date: 10/27/2022
************************************************/


############################### QUESTION 1 ###############################
# a) Show the list of databases.
SHOW DATABASES;

# b) Select sakila database.
USE SAKILA;

# c) Show all tables in the sakila database.
SHOW TABLES;

# d) Show each of the columns along with their data types for the actor table.
DESCRIBE SAKILA.ACTOR;

# e) Show the total number of records in the actor table.
SELECT COUNT(*) 
FROM SAKILA.ACTOR;

# f) What is the first name and last name of all the actors in the actor table (only show unique names)?

SELECT
DISTINCT FIRST_NAME, 
		 LAST_NAME
FROM SAKILA.ACTOR;

# g) Insert your first name and middle initial ( in the last name column ) into the actors table.

INSERT INTO `ACTOR`
(`ACTOR_ID`, `FIRST_NAME`, `LAST_NAME`, `LAST_UPDATE`)
VALUES ('555', 'LUKE', 'M', CURRENT_TIMESTAMP);

# h) Update your middle initial with your last name in the actors table.

UPDATE ACTOR 
SET 
	LAST_NAME = 'SCHWENKE'
WHERE
	LAST_NAME = 'M';

# i) Delete the record from the actor table where the first name matches your first name.

DELETE FROM ACTOR 
WHERE FIRST_NAME = 'LUKE';

# SELECT * FROM ACTOR WHERE FIRST_NAME = 'LUKE';

# j) Create a table payment_type with the following specifications and appropriate data types
# Table Name : “Payment_type”
# Primary Key: "payment_type_id”
# Column: “Type”
# Insert following rows in to the table: 1, “Credit Card” ; 2, “Cash”; 3, “Paypal” ; 4 , “Cheque”

CREATE TABLE `Payment_type` (
`payment_type_id` INT(1) NOT NULL,
`type` VARCHAR(15) NOT NULL,
PRIMARY KEY (`payment_type_id`))
ENGINE=INNODB DEFAULT CHARSET=LATIN1;

INSERT INTO `Payment_type`
(`payment_type_id`, `type`)
VALUES
(1, 'Credit Card'),
(2, 'Cash'),
(3, 'Paypal'),
(4, 'Cheque');

# k) Rename table payment_type to payment_types.

RENAME TABLE payment_type TO payment_types;
# SELECT * FROM PAYMENT_TYPES;

# l) Drop the table payment_types.

DROP TABLE payment_types;

############################### QUESTION 2 ############################### 
# a) List all the movies ( title & description ) that are rated PG-13 ?

SELECT TITLE,
	   DESCRIPTION
FROM FILM 
WHERE RATING = 'PG-13';

# b) List all movies that are either PG OR PG-13 using IN operator ?

SELECT *
FROM FILM
WHERE RATING IN ('PG', 'PG-13');

# c) Report all payments greater than and equal to $2 and Less than equal to $7 ? 
# Note : write 2 separate queries conditional operator and BETWEEN keyword

# Query 1
SELECT *
FROM PAYMENT
WHERE AMOUNT >= 2 AND AMOUNT <= 7;

# Query 2
SELECT *
FROM PAYMENT
WHERE AMOUNT BETWEEN 2 AND 7;


# d) List all addresses that have phone number that contain digits 589. 
# A separate query for phone numbers that start with 140, and a third query that ends with 589
# Note : write 3 different queries

SELECT *
FROM ADDRESS
WHERE PHONE LIKE '%589%';

SELECT *
FROM ADDRESS
WHERE PHONE LIKE '140%';

SELECT *
FROM ADDRESS
WHERE PHONE LIKE '%589';

# e) List all staff members ( first name, last name, email ) whose password is NULL ?

SELECT FIRST_NAME,
	   LAST_NAME,
	   EMAIL
FROM STAFF 
WHERE PASSWORD IS NULL;

# f) Select all films that have title names like ZOO and rental duration greater than or equal to 4

SELECT *
FROM FILM
WHERE TITLE LIKE '%ZOO%' AND RENTAL_DURATION >= 4;

# g) What is the cost of renting the movie ACADEMY DINOSAUR for 2 weeks ? Note : use of column alias

SELECT RENTAL_RATE, 
	   RENTAL_DURATION, 
       RENTAL_RATE * 14/RENTAL_DURATION AS TWO_WEEK_COST # 14 Days / 6 Day Rate Duration * the Rate for 6 days
FROM FILM
WHERE TITLE = 'ACADEMY DINOSAUR'; # Answer = 2.31

# h) List all unique districts where the customers, staff, and stores are located Note : check for NOT NULL values

SELECT DISTINCT DISTRICT
FROM ADDRESS
WHERE DISTRICT IS NOT NULL; 

# i) List the top 10 newest customers across all stores

SELECT C.CUSTOMER_ID,
       C.FIRST_NAME,
       C.LAST_NAME
FROM CUSTOMER AS C
ORDER BY CREATE_DATE DESC
LIMIT 10;

############################### QUESTION 3 ############################### 
# a) Show total number of movies

SELECT COUNT(*) 
FROM FILM; # 1,000

# b) What is the minimum payment received and max payment received across all transactions ?

SELECT MIN(PAY.AMOUNT) AS MIN_PAYMENT_AMOUNT, 
	   MAX(PAY.AMOUNT) AS MAX_PAYMENT_AMOUNT
FROM PAYMENT AS PAY;

# c) Number of customers that rented movies between Feb-2005 & May-2005 ( based on paymentDate ). 

SELECT COUNT(*)
FROM CUSTOMER AS C
LEFT JOIN PAYMENT AS PAY ON PAY.CUSTOMER_ID = C.CUSTOMER_ID
WHERE PAY.PAYMENT_DATE BETWEEN '2005-02-01' AND '2005-05-31'; #994, alternative: '2005-02-01 00:00:00' AND '2005-05-31 23:59:59' #1,157

# d) List all movies where replacement_cost is greater than $15 or rental_duration is between 6 & 10 days 

SELECT * 
FROM FILM
WHERE REPLACEMENT_COST > 15 
OR RENTAL_DURATION BETWEEN 6 AND 10; #819

# e) What is the total amount spent by customers for movies in the year 2005 ?

SELECT SUM(AMOUNT) AS TOTAL_AMOUNT
FROM PAYMENT
WHERE YEAR(PAYMENT_DATE) = '2005'; # $66,902.33

# f) What is the average replacement cost across all movies ?

SELECT AVG(REPLACEMENT_COST)
FROM FILM; # $19.984

# g) What is the standard deviation of rental rate across all movies ?

SELECT STDDEV(RENTAL_RATE)
FROM FILM; # $1.645

# h) What is the midrange of the rental duration for all movies 

SELECT (MAX(RENTAL_DURATION) + MIN(RENTAL_DURATION)) / 2 AS RENTAL_MIDRANGE
FROM FILM; # 5.0

############################### QUESTION 4 ############################### 
# a) Customers sorted by first Name and last name in ascending order.

SELECT FIRST_NAME,
	   LAST_NAME
FROM CUSTOMER
ORDER BY 1 ASC; # Sort on column index 1 (first_name)

# b) Count of movies that are either G/NC-17/PG-13/PG/R grouped by rating.

SELECT RATING,
	   COUNT(*) AS COUNTS
FROM FILM
GROUP BY RATING;

# c) Number of addresses in each district.

SELECT DISTRICT, 
	   COUNT(DISTINCT(ADDRESS)) AS DISTINCT_ADDRESSES
FROM ADDRESS
GROUP BY DISTRICT
ORDER BY 2 DESC;

# d) Find the movies where rental rate is greater than $1 and order result set by descending order.

SELECT TITLE, 
	   RENTAL_RATE
FROM FILM
WHERE RENTAL_RATE > 1 
ORDER BY 2 DESC;

# e) Top 2 movies that are rated R with the highest replacement cost ?

SELECT TITLE, 
	   RATING, 
       REPLACEMENT_COST
FROM FILM
WHERE RATING = 'R'
ORDER BY REPLACEMENT_COST DESC, 
		 TITLE ASC
LIMIT 2; # NOTE: Multiple movies have a replacement cost of $29.99

# f) Find the most frequently occurring (mode) rental rate across products.

SELECT RENTAL_RATE, 
	   COUNT(*) AS OCCURRENCES
FROM FILM
GROUP BY RENTAL_RATE
ORDER BY 2 DESC
LIMIT 1; # $0.99 (341 occurrences)

# g) Find the top 2 movies with movie length greater than 50mins and which has commentaries as a special features.

SELECT TITLE, 
	   LENGTH, 
       SPECIAL_FEATURES
FROM FILM
WHERE LENGTH > 50 AND SPECIAL_FEATURES LIKE '%COMMENTARIES%' # Note: Remove % to search for Commentaries exactly
ORDER BY 2 DESC
LIMIT 2; # Note: more than 2 movies have commentary special features and are greater than 50 mins.

# h) List the years with more than 2 movies released.

SELECT RELEASE_YEAR, 
	   COUNT(*) AS MOVIE_COUNT
FROM FILM
GROUP BY RELEASE_YEAR
HAVING COUNT(*) > 2;



